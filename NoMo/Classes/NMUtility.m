//
//  NMUtility.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMUtility.h"


@implementation NMUtility

+ (NSInteger)randomIntegerWithMaxValue:(NSInteger)maxValue
{
	return [self randomIntegerWithMinValue:0 maxValue:maxValue];
}

+ (NSInteger)randomIntegerWithMinValue:(NSInteger)minValue maxValue:(NSInteger)maxValue
{
	return (NSInteger)[self randomDoubleWithMinValue:minValue maxValue:maxValue];
}

+ (double)randomDoubleWithMaxValue:(double)maxValue
{
	return [self randomDoubleWithMinValue:0.0 maxValue:maxValue];
}

+ (double)randomDoubleWithMinValue:(double)minValue maxValue:(double)maxValue
{
	return minValue + (maxValue - minValue) * (double)arc4random() / UINT32_MAX;
}

+ (NSTimeInterval)randomTimeIntervalWithMinValue:(NSTimeInterval)minValue maxValue:(NSTimeInterval)maxValue
{
	return minValue + (maxValue - minValue) * (double)arc4random() / UINT32_MAX;
}

@end
