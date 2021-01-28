//
//  DirectIDOAuth2Settings.h
//  NoMo
//
//  Created by Costas Harizakis on 9/29/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface DirectIDOAuth2Settings : NSObject

+ (NSString *)authority;
+ (NSString *)resourceName;
+ (NSString *)clientIdentifier;
+ (NSString *)clientSecret;

@end
