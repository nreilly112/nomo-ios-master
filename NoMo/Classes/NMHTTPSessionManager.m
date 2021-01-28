//
//  NMHTTPSessionManager.m
//  NoMo
//
//  Created by Costas Harizakis on 10/4/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMHTTPSessionManager.h"


@interface NMHTTPSessionManager ()

- (void)updateAuthorizationHeaderField;

@end


@implementation NMHTTPSessionManager

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[_securityContext removeObserver:self forKeyPath:@"accessToken" context:NULL];
}

#pragma mark - [ Initializers ]

- (instancetype)initWithBaseURL:(NSURL *)url
		   sessionConfiguration:(NSURLSessionConfiguration *)configuration
{
	return [self initWithBaseURL:url sessionConfiguration:configuration securityContext:nil];
}

- (instancetype)initWithBaseURL:(NSURL *)url
		   sessionConfiguration:(NSURLSessionConfiguration *)configuration
				securityContext:(NMSecurityContext *)securityContext
{
	self = [super initWithBaseURL:url sessionConfiguration:configuration];
	
	if (self) {
		_securityContext = securityContext;
		[_securityContext addObserver:self forKeyPath:@"accessToken" options:NSKeyValueObservingOptionNew context:NULL];

		[self updateAuthorizationHeaderField];
	}
	
	return self;
}

#pragma mark - [ NSKeyValueObservable ]

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
	if ((object == _securityContext) && ([keyPath isEqualToString:@"accessToken"])) {
		[self updateAuthorizationHeaderField];
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark - [ Methods ]

- (void)updateAuthorizationHeaderField
{
	id<NMToken> accessToken = _securityContext.accessToken;
	
	if (accessToken) {
		[self setAuthorizationHeaderFieldWithAccessToken:accessToken];
	}
}

@end
