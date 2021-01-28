//
//  NMSummaryMessageItem.m
//  NoMo
//
//  Created by Costas Harizakis on 11/1/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMSummaryMessageItem.h"


#define kPersonaKey @"level"
#define kCurrencyCodeKey @"currency"
#define kMinimumValueKey @"min"
#define kMaximumValueKey @"max"
#define kTextKey @"text"


@implementation NMSummaryMessageItem

#pragma mark - [ Initializers ]

- (instancetype)initWithProperties:(NSDictionary *)properties
{
	self = [super initWithProperties:properties];
	
	if (self) {
		_persona = [properties integerValueOrZeroForKey:kPersonaKey];
		_currencyCode = [[properties objectOrNilForKey:kCurrencyCodeKey] copy];
		_minimumValue = [properties doubleValueOrZeroForKey:kMinimumValueKey notFound:-DBL_MAX];
		_maximumValue = [properties doubleValueOrZeroForKey:kMaximumValueKey notFound:DBL_MAX];
		_text = [[properties objectOrNilForKey:kTextKey] copy];
	}
	
	return self;
}

#pragma mark - [ Properties ]

- (NSMutableDictionary *)properties
{
	NSMutableDictionary *properties = [super properties];
	
	[properties setIntegerValue:_persona forKey:kPersonaKey];
	[properties setObjectOrNil:_currencyCode forKey:kCurrencyCodeKey];
	
	if (_minimumValue != -DBL_MAX) {
		[properties setDoubleValue:_minimumValue forKey:kMinimumValueKey];
	}
	if (_maximumValue != DBL_MAX) {
		[properties setDoubleValue:_maximumValue forKey:kMaximumValueKey];
	}
	
	[properties setObjectOrNil:_text forKey:kTextKey];
	
	return properties;
}

@end


@implementation NMSummaryMessageItem (Compare)

- (BOOL)canUseWithPersona:(NMApplicationPersona)persona forAmount:(NMAmount *)amount
{
	if ((_persona == persona)
	 && ((_currencyCode == nil) || [_currencyCode isEqualToString:amount.currencyCode])
	 && ((_minimumValue <= amount.value) && (amount.value < _maximumValue))) {
		return YES;
	}
	
	return NO;
}

@end
