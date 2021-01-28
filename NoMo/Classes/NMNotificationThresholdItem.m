//
//  NMNotificationThresholdItem.m
//  NoMo
//
//  Created by Costas Harizakis on 07/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMNotificationThresholdItem.h"


#define kCurrencyCodeKey @"currency"
#define kMinimumAllowedValueKey @"min"
#define kMaximumAllowedValueKey @"max"


@implementation NMNotificationThresholdItem

#pragma mark - [ Initializers ]

- (instancetype)initWithProperties:(NSDictionary *)properties
{
	self = [super initWithProperties:properties];
	
	if (self) {
		_currencyCode = [[properties objectOrNilForKey:kCurrencyCodeKey] copy];
		_minimumAllowedValue = [properties doubleValueOrZeroForKey:kMinimumAllowedValueKey notFound:1.0];
		_maximumAllowedValue = [properties doubleValueOrZeroForKey:kMaximumAllowedValueKey notFound:1000.0];
	}
	
	return self;
}

#pragma mark - [ Properties ]

- (NSMutableDictionary *)properties
{
	NSMutableDictionary *properties = [super properties];
	[properties setObjectOrNil:_currencyCode forKey:kCurrencyCodeKey];
	[properties setDoubleValue:_minimumAllowedValue forKey:kMinimumAllowedValueKey];
	[properties setDoubleValue:_maximumAllowedValue forKey:kMaximumAllowedValueKey];
	
	return properties;
}

@end
