//
//  NMAmount.h
//  NoMo
//
//  Created by Costas Harizakis on 01/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface NMAmount : NSObject <NSCopying>

@property (nonatomic, assign, readonly) double value;
@property (nonatomic, copy, readonly) NSString *currencyCode;

- (instancetype)initWithValue:(double)value currencyCode:(NSString *)currencyCode;
+ (instancetype)amountWithValue:(double)value currencyCode:(NSString *)currencyCode;

- (NMAmount *)addAmount:(NMAmount *)amount;
- (NMAmount *)subtractAmount:(NMAmount *)amount;

- (NMAmount *)absoluteAmount;

@end
