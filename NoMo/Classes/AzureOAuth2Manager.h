//
//  AzureOAuth2Manager.h
//  NoMo
//
//  Created by Costas Harizakis on 9/27/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "NMOAuth2Credentials.h"


@interface AzureOAuth2Manager : AFHTTPSessionManager

- (NSURLSessionDataTask *)getAccessTokenWithAuthority:(NSString *)authority
											 resource:(NSString *)resource
										  credentials:(id<NMOAuth2Credentials>)credentials
									completionHandler:(NMJSONObjectCompletionHandler)completionHandler;

+ (instancetype)defaultManager;

@end
