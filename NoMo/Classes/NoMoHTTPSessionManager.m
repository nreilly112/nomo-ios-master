//
//  NoMoHTTPSessionManager.m
//  NoMo
//
//  Created by Costas Harizakis on 9/27/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoHTTPSessionManager.h"
#import "NoMoSecurityContext.h"
#import "NoMoSettings.h"


@implementation NoMoHTTPSessionManager

#pragma mark - [ Initializers ]

- (instancetype)initWithBaseURL:(NSURL *)url
		   sessionConfiguration:(NSURLSessionConfiguration *)configuration
				securityContext:(NMSecurityContext *)securityContext
{
	return [super initWithBaseURL:url
			 sessionConfiguration:configuration
				  securityContext:securityContext ?: [NoMoSecurityContext defaultContext]];
}

#pragma mark - [ Singleton ]

+ (instancetype)defaultManager
{
	static NoMoHTTPSessionManager *instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		NSURL *baseURL = [NoMoSettings apiBaseURL];
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
		NMSecurityContext *securityContext = [NoMoSecurityContext defaultContext];

		instance = [[NoMoHTTPSessionManager alloc] initWithBaseURL:baseURL
											  sessionConfiguration:configuration
												   securityContext:securityContext];
		[instance.requestSerializer setValue:@"IOS" forHTTPHeaderField:@"X-Client"];
		[instance.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		[instance.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	});
	
	return instance;
}

@end
