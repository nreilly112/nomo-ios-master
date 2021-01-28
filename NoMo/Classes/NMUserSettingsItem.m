//
//  NMUserSettingsItem.m
//  NoMo
//
//  Created by Costas Harizakis on 9/26/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMUserSettingsItem.h"


#define kPreferredCurrencyCodeKey @"preferredCurrencyCode"
#define kIncrementNotificationThresholdKey @"incrementNotificationThreshold"
#define kDecrementNotificationThresholdKey @"decrementNotificationThreshold"
#define kApplicationPersonaKey @"applicationPersona"
#define kNotificationsEnabledKey @"notificationsEnabled"
#define kOverdraftEnabledKey @"includeOverdraft"


@implementation NMUserSettingsItem

#pragma mark - [ Initializers ]

- (instancetype)initWithProperties:(NSDictionary *)properties
{
	self = [super init];
	
	if (self) {
		_preferredCurrencyCode = [[properties objectOrNilForKey:kPreferredCurrencyCodeKey] copy];
		_incrementNotificationThreshold = [properties doubleValueOrZeroForKey:kIncrementNotificationThresholdKey];
		_decrementNotificationThreshold = [properties doubleValueOrZeroForKey:kDecrementNotificationThresholdKey];
		_applicationPersona = [properties integerValueOrZeroForKey:kApplicationPersonaKey];
		_notificationsEnabled = [properties integerValueOrZeroForKey:kNotificationsEnabledKey];
        _includeOverdraft = [properties integerValueOrZeroForKey:kOverdraftEnabledKey];
	}
	
	return self;
}

#pragma mark - [ Properties ]

- (NSMutableDictionary *)properties
{
	NSMutableDictionary *properties = [super properties];
	[properties setObjectOrNil:_preferredCurrencyCode forKey:kPreferredCurrencyCodeKey];
	[properties setDoubleValue:_incrementNotificationThreshold forKey:kIncrementNotificationThresholdKey];
	[properties setDoubleValue:_decrementNotificationThreshold forKey:kDecrementNotificationThresholdKey];
	[properties setIntegerValue:_applicationPersona forKey:kApplicationPersonaKey];
	[properties setIntegerValue:_notificationsEnabled forKey:kNotificationsEnabledKey];
    [properties setIntegerValue:_includeOverdraft forKey:kOverdraftEnabledKey];
	
	return properties;
}

@end
