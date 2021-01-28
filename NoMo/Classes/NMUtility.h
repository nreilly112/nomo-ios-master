//
//  NMUtility.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface NMUtility : NSObject

+ (NSInteger)randomIntegerWithMaxValue:(NSInteger)maxValue;
+ (NSInteger)randomIntegerWithMinValue:(NSInteger)minValue maxValue:(NSInteger)maxValue;
+ (double)randomDoubleWithMaxValue:(double)maxValue;
+ (double)randomDoubleWithMinValue:(double)minValue maxValue:(double)maxValue;
+ (NSTimeInterval)randomTimeIntervalWithMinValue:(NSTimeInterval)minValue maxValue:(NSTimeInterval)maxValue;

@end