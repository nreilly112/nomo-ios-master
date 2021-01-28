//
//  DirectIDSettings.m
//  NoMo
//
//  Created by Costas Harizakis on 05/12/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "DirectIDSettings.h"


@implementation DirectIDSettings

+ (NSURL *)widgetBaseURL
{
    #ifdef DEBUG
        return [NSURL URLWithString:@"https://nomo-cap.azurewebsites.net/widget/"];
    #else
        return [NSURL URLWithString:@"https://api-nomo.directid.co/widget/"];
    #endif
}

+ (NSURL *)styleBaseURL
{
    return [NSURL URLWithString:@"https://directid-cdn.azureedge.net/widget/latest/prod-uks/"];
}

@end
