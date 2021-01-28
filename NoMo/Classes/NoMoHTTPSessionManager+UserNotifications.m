//
//  NoMoHTTPSessionManager+UserNotifications.m
//  NoMo
//
//  Created by Costas Harizakis on 9/24/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoHTTPSessionManager.h"
#import "NMDevice.h"


@implementation NoMoHTTPSessionManager (UserNotifications)

- (NSURLSessionDataTask *)registerDeviceToken:(NSString *)deviceToken
						  completionHandler:(NMJSONObjectCompletionHandler)completionHandler
{
	NSString *path = [NSString stringWithFormat:@"./Notifications/register"];
	NSDictionary *parameters = @{ @"handle": deviceToken ?: [NSNull null] };

	//NSLog(@"[NoMoHTTPSessionManager] [Updating device token (payload follows)]");
	//NSLog(@"\n%@", parameters);

	return [self post:path parameters:parameters completed:^(NSURLSessionDataTask *task, id json, NSError *error) {
		if (error == nil) {
            NSDictionary *properties = json;
			completionHandler(task, properties, nil);
		}
		else {
			completionHandler(task, nil, error);
		}
	}];
}

- (NSURLSessionDataTask *)registerUserWithRegistrationId:(NSString *)registrationId
                                             deviceToken:(NSString *)deviceToken
                                            completionHandler:(NMCompletionHandler)completionHandler
{
    NSString *path = [NSString stringWithFormat:@"./Notifications/register/%@", registrationId];
    NSDictionary *parameters = @{ @"handle": deviceToken ?: [NSNull null],
                                  @"platform": @"apns",
                                  @"tags": @[]  };
    NSData *data = [parameters JSONData];
  //  NSLog(@"[NoMoHTTPSessionManager] [Updating user with data: ]");
  //  NSLog(@"\nregistration id: %@, parameters: %@", registrationId, parameters);
    
    return [self put:path parameters:nil data:data completed:^(NSURLSessionDataTask *task, NSError *error) {
        if (error == nil) {
            completionHandler(task, nil);
        }
        else {
            completionHandler(task, error);
        }
    }];
}

@end
