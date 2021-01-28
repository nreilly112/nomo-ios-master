//
//  DirectIDOAuth2Settings.m
//  NoMo
//
//  Created by Costas Harizakis on 9/29/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "DirectIDOAuth2Settings.h"


@implementation DirectIDOAuth2Settings

+ (NSString *)authority
{
	return @"directiddirectory.onmicrosoft.com";
}

+ (NSString *)resourceName
{
	return @"https://directiddirectory.onmicrosoft.com/DirectID.API";
}

+ (NSString *)clientIdentifier
{
	return @"(client-id)";
}

+ (NSString *)clientSecret
{
	return @"(client-secret)";
}

@end
