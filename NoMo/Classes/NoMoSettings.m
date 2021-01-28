//
//  NoMoSettings.m
//  NoMo
//
//  Created by Costas Harizakis on 9/27/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoSettings.h"


@implementation NoMoSettings

+ (NSString *)authorizationToken
{
	return @"aW9zOkFYdldlTmNHTG15c3p5Q2dCek1oaw==";
}

+ (NSString *)clientSecret {
    return @"AXvWeNcGLmyszyCgBzMhk";
}

+ (NSString *)clientId {
    return @"ios";
}

+ (NSString *)scope {
    return @"nomo";
}

+ (NSString *)grantType {
    return @"client_credentials";
}

+ (NSURL *)contentBaseURL
{
	return [NSURL URLWithString:@"https://nomoblob.blob.core.windows.net/nomo-public-files/"];
}

+ (NSURL *)baseURL
{
    #ifdef DEBUG
        return [NSURL URLWithString:@"https://nomo-cap.azurewebsites.net/"];
    #else
        return [NSURL URLWithString:@"https://api-nomo.directid.co/"];
    #endif
}

+ (NSURL *)apiBaseURL
{
    #ifdef DEBUG
        return [NSURL URLWithString:@"https://nomo-cap.azurewebsites.net/api/"];
    #else
        return [NSURL URLWithString:@"https://api-nomo.directid.co/api/"];
    #endif
}

+ (NSString *)widgetRedirectURL
{
    #ifdef DEBUG
        return @"did://didFlowComplete";
    #else
        return @"did://didFlowComplete";
    #endif
}

@end
