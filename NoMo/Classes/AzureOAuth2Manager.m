//
//  AzureOAuth2Manager.m
//  NoMo
//
//  Created by Costas Harizakis on 9/27/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "AzureOAuth2Manager.h"


@implementation AzureOAuth2Manager

#pragma mark - [ Methods ]

- (NSURLSessionDataTask *)getAccessTokenWithAuthority:(NSString *)authority
											 resource:(NSString *)resource
										  credentials:(id<NMOAuth2Credentials>)credentials
									completionHandler:(NMJSONObjectCompletionHandler)completionHandler
{
	NSString *path = [NSString stringWithFormat:@"./%@/oauth2/token", authority];
	NSDictionary *parameters = @{ @"client_id": credentials.clientId,
								  @"client_secret": credentials.clientSecret,
								  @"grant_type": @"client_credentials",
								  @"resource": resource ?: @"" };
	
	return [self post:path parameters:parameters completed:^(NSURLSessionDataTask *task, id data, NSError *error) {
		if (error == nil) {
			NSDictionary *properties = data;
			
			if (properties == nil) {
				NSError *error = [NSError errorWithDomain:@"OAuth2" code:-1 userInfo:nil];
				completionHandler(task, nil, error);
			}
			else if ([properties containsKey:@"error"]) {
				NSError *error = [NSError errorWithDomain:@"OAuth2" code:-2 userInfo:nil];
				completionHandler(task, nil, error);
			}
			else {
				completionHandler(task, data, nil);
			}
		}
		else {
			completionHandler(task, nil, error);
		}
	}];
}

#pragma mark - [ Singleton ]

+ (instancetype)defaultManager
{
	static AzureOAuth2Manager *instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		NSURL *baseURL = [NSURL URLWithString:@"https://login.windows.net/"];
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
		instance = [[AzureOAuth2Manager alloc] initWithBaseURL:baseURL sessionConfiguration:configuration];
	});
	
	return instance;
}

@end
