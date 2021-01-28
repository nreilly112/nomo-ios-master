//
//  NoMoHTTPSessionManager+UserSettings.m
//  NoMo
//
//  Created by Costas Harizakis on 9/26/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoHTTPSessionManager.h"


@implementation NoMoHTTPSessionManager (UserSettings)

- (NSURLSessionDataTask *)getSettingsForUserWithIdentity:(id<NMIdentity>)userIdentity
									   completionHandler:(NMJSONObjectCompletionHandler)completionHandler
{
	NSString *path = [NSString stringWithFormat:@"./Settings"];
	NSDictionary *parameters = @{ };
	
	return [self get:path parameters:parameters completed:^(NSURLSessionDataTask *task, id json, NSError *error) {
		if (error == nil) {
			NSDictionary *properties = json;
			completionHandler(task, properties, nil);
		}
		else {
			completionHandler(task, nil, error);
		}
	}];
}

- (NSURLSessionDataTask *)updateSettings:(id<NMUserSettings>)settings
					 forUserWithIdentity:(id<NMIdentity>)userIdentity
					   completionHandler:(NMCompletionHandler)completionHandler
{
	NSString *path = [NSString stringWithFormat:@"./settings"];
	NSDictionary *parameters = @{ @"preferredCurrencyCode": settings.preferredCurrencyCode ?: [NSNull null],
								  @"incrementNotificationThreshold": @(settings.incrementNotificationThreshold),
								  @"decrementNotificationThreshold": @(settings.decrementNotificationThreshold),
								  @"applicationPersona": @(settings.applicationPersona),
								  @"notificationsEnabled": @(settings.notificationsEnabled),
                                  @"includeOverdraft": @(settings.includeOverdraft)
                                  };
	NSData *data = [parameters JSONData];
	
	//NSLog(@"[NoMoHTTPSessionManager] [Updating settings (payload follows)]");
	//NSLog(@"\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	
	return [self put:path parameters:nil data:data completed:^(NSURLSessionDataTask *task, NSError *error) {
		if (error == nil) {
			completionHandler(task, nil);
		}
		else {
			NSLog(@"[NoMoHTTPSessionManager] [Failed to update settings (Error: %@)]", error.description);
			completionHandler(task, error);
		}
	}];
}



@end
