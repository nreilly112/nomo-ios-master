//
//  DirectIDAuthenticationManager.m
//  NoMo
//
//  Created by Costas Harizakis on 13/12/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "DirectIDAuthenticationManager.h"
#import "DirectIDOAuth2Settings.h"
#import "AzureOAuth2Manager.h"


@implementation DirectIDAuthenticationManager (Authentication)

- (NSURLSessionDataTask *)getAccessTokenWithCompletionHandler:(NMJSONObjectCompletionHandler)completionHandler
{
	AzureOAuth2Manager *manager = [AzureOAuth2Manager defaultManager];
	
	NSString *authority = [DirectIDOAuth2Settings authority];
	NSString *resourceName = [DirectIDOAuth2Settings resourceName];
	NMOAuth2Credentials *credentials = [NMOAuth2Credentials credentialsWithClientId:[DirectIDOAuth2Settings clientIdentifier]
																	   clientSecret:[DirectIDOAuth2Settings clientSecret]];
	
	return [manager getAccessTokenWithAuthority:authority
									   resource:resourceName
									credentials:credentials
							  completionHandler:completionHandler];
}

@end


@implementation DirectIDAuthenticationManager

#pragma mark - [ Singleton ]

+ (instancetype)defaultManager
{
	static DirectIDAuthenticationManager *instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
		instance = [[DirectIDAuthenticationManager alloc] initWithSessionConfiguration:configuration];
	});
	
	return instance;
}

@end
