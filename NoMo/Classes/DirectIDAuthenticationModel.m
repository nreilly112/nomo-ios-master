//
//  NMSessionTokenModel.m
//  NoMo
//
//  Created by Costas Harizakis on 08/12/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "DirectIDAuthenticationModel.h"
#import "DirectIDSecurityContext.h"
#import "DirectIDAuthenticationManager.h"


@interface DirectIDAuthenticationModel ()

@property (nonatomic, copy) NSString *tokenString;
@property (nonatomic, copy) NSDate *expirationDate;
@property (nonatomic, strong) NSURLSessionDataTask *loadTask;

- (void)updateSecurityContext;

@end


@implementation DirectIDAuthenticationModel

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[self invalidate];
}

#pragma mark - [ Initializers ]

- (instancetype)init
{
	return [self initWithSecurityContext:nil];
}

- (instancetype)initWithSecurityContext:(NMSecurityContext *)securityContext
{
	self = [super init];
	
	if (self) {
		_securityContext = securityContext;
		_tokenString = nil;
		_expirationDate = nil;
		_loadTask = nil;
	}
	
	return self;
}

#pragma mark - [ NMModel ]

- (void)didChange
{
	[self updateSecurityContext];
	[super didChange];
}

- (void)invalidate
{
	[super invalidate];
	[self cancelLoad];
	
	_tokenString = nil;
	_expirationDate = nil;
}

- (BOOL)canLoad
{
	if (_loadTask) {
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
				_tokenString = [properties objectOrNilForKey:@"access_token"];
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
	
	DirectIDAuthenticationManager *manager = [DirectIDAuthenticationManager defaultManager];
	
	_loadTask = [manager getAccessTokenWithCompletionHandler:completionHandler];

	if (_loadTask == nil) {
		return NO;
	}
	
	[self didStartLoad];
	
	return YES;
}

- (void)cancelLoad
{
	if (_loadTask) {
		NSURLSessionDataTask *task = _loadTask;
		
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

#pragma mark - [ Static Methods ]

+ (instancetype)sharedModel
{
	static DirectIDAuthenticationModel *instance;
	static dispatch_once_t once;
	
	dispatch_once(&once, ^(void) {
		DirectIDSecurityContext *securityContext = [DirectIDSecurityContext defaultContext];
		
		instance = [[DirectIDAuthenticationModel alloc] initWithSecurityContext:securityContext];
	});
	
	return instance;
}

@end
