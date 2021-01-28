//
//  NoMoHTTPSessionManager.h
//  NoMo
//
//  Created by Costas Harizakis on 9/27/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMHTTPSessionManager.h"
#import "NMIdentity.h"
#import "NMSecurityContext.h"
#import "NMUserSettings.h"


@interface NoMoHTTPSessionManager : NMHTTPSessionManager

+ (instancetype)defaultManager;

@end


@interface NoMoHTTPSessionManager (Session)

- (NSURLSessionDataTask *)getSessionValidationStateForUserWithIdentity:(id<NMIdentity>)userIdentity
													 completionHandler:(NMJSONObjectCompletionHandler)completionHandler;

- (NSURLSessionDataTask *)invalidateSessionForUserWithIdentity:(id<NMIdentity>)userIdentity
											 completionHandler:(NMCompletionHandler)completionHandler;

@end


@interface NoMoHTTPSessionManager (UserFinance)

- (NSURLSessionDataTask *)getFinancialStatementForUserWithIdentity:(id<NMIdentity>)userIdentity
												 completionHandler:(NMJSONObjectCompletionHandler)completionHandler;

@end


@interface NoMoHTTPSessionManager (UserNotifications)

- (NSURLSessionDataTask *)registerDeviceToken:(NSString *)deviceToken
                            completionHandler:(NMJSONObjectCompletionHandler)completionHandler;

- (NSURLSessionDataTask *)registerUserWithRegistrationId:(NSString *)registrationId
                                             deviceToken:(NSString *)deviceToken
                                       completionHandler:(NMCompletionHandler)completionHandler;

@end


@interface NoMoHTTPSessionManager (UserSettings)

- (NSURLSessionDataTask *)getSettingsForUserWithIdentity:(id<NMIdentity>)userIdentity
									   completionHandler:(NMJSONObjectCompletionHandler)completionHandler;

- (NSURLSessionDataTask *)updateSettings:(id<NMUserSettings>)settings
					 forUserWithIdentity:(id<NMIdentity>)userIdentity
					   completionHandler:(NMCompletionHandler)completionHandler;

@end
