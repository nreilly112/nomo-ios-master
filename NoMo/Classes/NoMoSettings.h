//
//  NoMoSettings.h
//  NoMo
//
//  Created by Costas Harizakis on 9/27/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface NoMoSettings : NSObject

+ (NSString *)authorizationToken;

+ (NSString *)clientId;
+ (NSString *)clientSecret;
+ (NSString *)scope;
+ (NSString *)grantType;

+ (NSURL *)contentBaseURL;
+ (NSURL *)baseURL;
+ (NSURL *)apiBaseURL;
+ (NSString *)widgetRedirectURL;

@end
