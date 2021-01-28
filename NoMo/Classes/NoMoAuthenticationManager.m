//
//  NoMoAuthenticationManager.m
//  NoMo
//
//  Created by Costas Harizakis on 10/3/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoAuthenticationManager.h"
#import "NoMoSettings.h"


@implementation NoMoAuthenticationManager

#pragma mark - [ Singleton ]

+ (instancetype)defaultManager
{
	static NoMoAuthenticationManager *instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		NSURL *baseURL = [NoMoSettings baseURL];
        NSString *authorizationToken = [NoMoSettings authorizationToken];
		NSString *authorizationFieldValue = [NSString stringWithFormat:@"Basic %@", authorizationToken];
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
		
		instance = [[NoMoAuthenticationManager alloc] initWithBaseURL:baseURL
												 sessionConfiguration:configuration];
		
		[instance.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
		[instance.requestSerializer setValue:authorizationFieldValue forHTTPHeaderField:@"Authorization"];
	});
	
	return instance;
}

@end
