//
//  NoMoUserSessionTokenModel.m
//  NoMo
//
//  Created by Costas Harizakis on 09/12/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoUserSessionTokenModel.h"
#import "NoMoAuthenticationManager.h"


@interface NoMoUserSessionTokenModel ()

@property (nonatomic, strong) NSURLSessionDataTask *loadTask;

@end


@implementation NoMoUserSessionTokenModel

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[self invalidate];
}

#pragma mark - [ Initializer ]

- (instancetype)init
{
	return [self initForUserWithIdentity:nil];
}

- (instancetype)initForUserWithIdentity:(id<NMIdentity>)userIdentity
{
	self = [super init];
	
	if (self) {
		_userIdentity = userIdentity;
		_tokenString = nil;
		_loadTask = nil;
	}
	
	return self;
}

#pragma mark - [ NMModel Methods ]

- (void)invalidate
{
	[super invalidate];
	[self cancelLoad];
	
	_tokenString = nil;
    _expiresIn = nil;
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
        if (self.loadTask == task) {
			self.loadTask = nil;
			
			if (error) {
				[self didFailLoadWithError:error];
			}
			else {
				self.tokenString = [properties objectOrNilForKey:@"access_token"];
				self.expiresIn = [properties objectOrNilForKey:@"expires_in"];
				
				NSLog(@"[NoMoUserSessionTokenModel] [Token: %@, Expires In: %@]", self.tokenString, self.expiresIn);
				
                [self getWidgetToken];
			}
		}
	};
	
	NoMoAuthenticationManager *manager = [NoMoAuthenticationManager defaultManager];
	
	_loadTask = [manager getAccessTokenWithUserIdentity:_userIdentity completionHandler:completionHandler];
	
	if (_loadTask == nil) {
		return NO;
	}
	
	[self didStartLoad];
	
	return YES;
}

-(BOOL) getWidgetToken {
    
    if (![self canLoad]) {
        return NO;
    }
    
    NMJSONObjectCompletionHandler completionHandler = ^(NSURLSessionDataTask *task, NSDictionary *properties, NSError *error) {
        if (self.loadTask == task) {
            self.loadTask = nil;
            
            if (error) {
                [self didFailLoadWithError:error];
            }
            else {
                self.accessToken = [properties objectOrNilForKey:@"accessToken"];
                self.sessionId = [properties objectOrNilForKey:@"userId"];
                self.widgetUrl = [properties objectOrNilForKey:@"widgetUrl"];
                
                [self setModified:NO];
                [self didFinishLoad];
                [self didChange];
            }
        }
    };
    
    NoMoAuthenticationManager *manager = [NoMoAuthenticationManager defaultManager];
    [self setAuthorizationHeader:manager];
    _loadTask = [manager getWidgetSessionTokenForAccessToken:_tokenString completionHandler:completionHandler];
    
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

-(void)setAuthorizationHeader:(NoMoAuthenticationManager *)manager{
    NSLog(@"setAuthorizationHeaderAAA: ");
    [manager.requestSerializer clearAuthorizationHeader];
    if (_tokenString) {
        NSString *tokenType = @"Bearer";
        NSString *tokenString = _tokenString;
        NSString *value = [NSString stringWithFormat:@"%@ %@", tokenType, tokenString];
        
        NSLog(@"[HTTPSessionManager] [Updating authorization header field (Value: %@)]", value);
        
        [manager.requestSerializer setValue:value forHTTPHeaderField:@"Authorization"];
    }
}

@end
