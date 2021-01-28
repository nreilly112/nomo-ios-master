//
//  NMDevice.m
//  NoMo
//
//  Created by Costas Harizakis on 10/6/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMDevice.h"

#define kDeviceIdKey @"deviceId"


@interface NMDevice ()

+ (NSString *)findOrCreateDeviceId;
+ (NSString *)createDeviceId;

@end


@implementation NMDevice

#pragma mark - [ Methods ]

+ (NSString *)uniqueIdentifier
{
	@synchronized(self) {
		return [NMDevice findOrCreateDeviceId];
	}
}

#pragma mark - [ Private Methods ]

+ (NSString *)_SECURE_findOrCreateDeviceId
{
	NSString *service = [[NSBundle mainBundle] bundleIdentifier];
	NSString *account = kDeviceIdKey;

	NSString *deviceId = [SAMKeychain passwordForService:service account:account];
	
	if (deviceId == nil) {
		deviceId = [NMDevice createDeviceId];
		[SAMKeychain setPassword:deviceId forService:service account:account];
	}
	
	return deviceId;
}

+ (NSString *)findOrCreateDeviceId
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	NSString *key = kDeviceIdKey;
	
	NSString *deviceId = [settings stringForKey:key];
	
	if (deviceId == nil) {
		deviceId = [NMDevice createDeviceId];
		[settings setObject:deviceId forKey:key];
		[settings synchronize];
	}
	
	return deviceId;
}

+ (NSString *)createDeviceId
{
	NSUUID *uuid = [NSUUID UUID];
	NSString *uuidString = [uuid UUIDString];
	
	return uuidString;
}

@end
