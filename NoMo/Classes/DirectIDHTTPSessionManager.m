//
//  DirectIDHTTPSessionManager.m
//  NoMo
//
//  Created by Costas Harizakis on 9/27/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "DirectIDHTTPSessionManager.h"
#import "DirectIDSecurityContext.h"
#import "DirectIdSettings.h"


@implementation DirectIDHTTPSessionManager

- (instancetype)initWithBaseURL:(NSURL *)url
		   sessionConfiguration:(NSURLSessionConfiguration *)configuration
				securityContext:(NMSecurityContext *)securityContext
{
	return [super initWithBaseURL:url
			 sessionConfiguration:configuration
				  securityContext:securityContext ?: [DirectIDSecurityContext defaultContext]];
}

#pragma mark - [ Singleton ]

+ (instancetype)defaultManager
{
	static DirectIDHTTPSessionManager *instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		NSURL *baseURL = [DirectIDSettings apiBaseURL];
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
		NMSecurityContext *securityContext = [DirectIDSecurityContext defaultContext];
		
		instance = [[DirectIDHTTPSessionManager alloc] initWithBaseURL:baseURL
												  sessionConfiguration:configuration
													   securityContext:securityContext];
	});
	
	return instance;
}

@end
