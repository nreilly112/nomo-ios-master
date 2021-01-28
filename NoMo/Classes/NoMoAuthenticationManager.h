//
//  NoMoAuthenticationManager.h
//  NoMo
//
//  Created by Costas Harizakis on 10/3/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "NMIdentity.h"


@interface NoMoAuthenticationManager : AFHTTPSessionManager

+ (instancetype)defaultManager;

@end


@interface NoMoAuthenticationManager (Authentication)

- (NSURLSessionDataTask *)getAccessTokenWithUserIdentity:(id<NMIdentity>)userIdentity
                                       completionHandler:(NMJSONObjectCompletionHandler)completionHandler;

- (NSURLSessionDataTask *)getWidgetSessionTokenForAccessToken:(NSString *)accessToken
                                            completionHandler:(NMJSONObjectCompletionHandler)completionHandler;

@end


@interface NoMoAuthenticationManager (Session)

- (NSURLSessionDataTask *)createSessionForUserWithIdentity:(id<NMIdentity>)userIdentity
                                                 sessionId:(NSString*)sessionId
										 completionHandler:(NMJSONObjectCompletionHandler)completionHandler;

- (NSURLSessionDataTask *)refreshSessionUsingTokenString:(NSString *)refreshToken
									   completionHandler:(NMJSONObjectCompletionHandler)completionHandler;


@end
