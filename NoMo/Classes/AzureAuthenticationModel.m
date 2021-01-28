//
//  AzureAuthenticationModel.m
//  NoMo
//
//  Created by Costas Harizakis on 9/27/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "AzureAuthenticationModel.h"
#import "AzureOAuth2Manager.h"


@interface AzureAuthenticationModel ()

@property (nonatomic, copy) NSString *tokenString;
@property (nonatomic, copy) NSDate *expirationDate;
@property (nonatomic, strong) NSURLSessionTask *loadTask;

- (void)updateSecurityContext;

@end


@implementation AzureAuthenticationModel

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[self cancelLoad];
}

#pragma mark - [ Initializer ]

- (instancetype)init
{
	return [self initWithSecurityContext:nil usingAuthority:nil];
}

- (instancetype)initWithSecurityContext:(NMSecurityContext *)securityContext
						 usingAuthority:(NSString *)authority
{
	self = [super init];
	
	if (self) {
		_securityContext = securityContext;
		_authority = [authority copy];
		_loadTask = nil;
	}
	
	return self;
}

#pragma mark - [ NMModel Methods ]

- (void)didChange
{
	[self updateSecurityContext];
	[super didChange];
}

- (void)invalidate
{
	[self cancelLoad];
	
	_tokenString = nil;
	_expirationDate = nil;
	
	[self setModified:NO];
	[self setLoaded:NO];
}

- (BOOL)canLoad
{
	if (_loadTask) {
		return NO;
	}
	if (_credentials == nil) {
		return NO;
	}

	return YES;
}

- (BOOL)load
{
	if (![self canLoad]) {
		return NO;
	}
	
	NMJSONObjectCompletionHandler completionHandler = ^(NSURLSessionDataTask *task, NSDictionary *properties, NSError *error) {
		if (_loadTask == task) {
			_loadTask = nil;
			
			if (error) {
				[self didFailLoadWithError:error];
			}
			else {
				_tokenString = [properties objectForKey:@"access_token"];
				_expirationDate = [NSDate distantFuture];
				
				if ([properties containsKey:@"expires_in"]) {
					NSTimeInterval expiresIn = [properties doubleValueOrZeroForKey:@"expires_in"];
					_expirationDate = [NSDate dateWithTimeIntervalSinceNow:expiresIn];
				}
				
				[self setModified:NO];
				[self didFinishLoad];
				[self didChange];
			}
		}
	};
	
	AzureOAuth2Manager *manager = [AzureOAuth2Manager defaultManager];
	
	_loadTask = [manager getAccessTokenWithAuthority:_authority
											resource:_resource
										 credentials:_credentials
								   completionHandler:completionHandler];
	if (!_loadTask) {
		return NO;
	}
	
	[_loadTask resume];
	[self didStartLoad];
	
	return YES;
}

- (void)cancelLoad
{
	if (_loadTask) {
		NSURLSessionTask *task = _loadTask;
		_loadTask = nil;
		
		[task cancel];
		
		[self didCancelLoad];
	}
}

#pragma mark - [ Private Methods ]

- (void)updateSecurityContext
{
	if (self.isLoaded) {
		NMToken *accessToken = [NMToken tokenWithTokenString:_tokenString
											  expirationDate:_expirationDate];
		
		_securityContext.accessToken = accessToken;
	}
}

@end


