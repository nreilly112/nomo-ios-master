//
//  NMAmount.m
//  NoMo
//
//  Created by Costas Harizakis on 01/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMAmount.h"


@implementation NMAmount

#pragma mark - [ Initializers ]

- (instancetype)init
{
	return [self initWithValue:0.0 currencyCode:nil];
}

- (instancetype)initWithValue:(double)value currencyCode:(NSString *)currencyCode
{
	self = [super init];
	
	if (self) {
		_value = value;
		_currencyCode  = [currencyCode copy];
	}
	
	return self;
}

+ (instancetype)amountWithValue:(double)value currencyCode:(NSString *)currencyCode
{
	return [[[self class] alloc] initWithValue:value currencyCode:currencyCode];
}

#pragma mark - [ Methods ]

- (NMAmount *)addAmount:(NMAmount *)amount
{
	if ([_currencyCode isEqualToString:amount.currencyCode]) {
		return [NMAmount amountWithValue:(_value + amount.value) currencyCode:_currencyCode];
	}
	
	return nil;
}

- (NMAmount *)subtractAmount:(NMAmount *)amount
{
	if ([_currencyCode isEqualToString:amount.currencyCode]) {
		return [NMAmount amountWithValue:(_value - amount.value) currencyCode:_currencyCode];
	}
	
	return nil;
}

- (NMAmount *)absoluteAmount
{
	return [NMAmount amountWithValue:fabs(_value) currencyCode:_currencyCode];
}

#pragma mark - [NSCopying ]

- (id)copyWithZone:(NSZone *)zone
{
	return [[NMAmount allocWithZone:zone] initWithValue:_value currencyCode:_currencyCode];
}

@end
