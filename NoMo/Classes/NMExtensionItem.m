//
//  NMExtensionItem.m
//  NoMo
//
//  Created by Costas Harizakis on 21/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMExtensionItem.h"


#define kDateKey @"date"
#define kHeadingKey @"heading"
#define kCommentKey @"comment"
#define kFundsBalanceValueKey @"fundsBalanceValueKey"
#define kFundsBalanceCurrencyCodeKey @"fundsBalanceCurrencyCodeKey"
#define kFundsHistoricAverageValueKey @"fundsHistoricAverageValueKey"
#define kFundsHistoricAverageCurrencyCodeKey @"fundsHistoricAverageCurrencyCodeKey"
#define kFundsGraphDataKey @"fundsGraphData"


@interface NMExtensionItem ()

@property (nonatomic, strong) UIImage *fundsGraphImage;
@property (nonatomic, strong) NSData *fundsGraphData;

@end


@implementation NMExtensionItem

#pragma mark - [ Initializer ]

- (instancetype)initWithProperties:(NSDictionary *)properties
{
	self = [super initWithProperties:properties];
	
	if (self) {
		_date = [[properties dateOrNilForKey:kDateKey] copy];
		_heading = [[properties objectOrNilForKey:kHeadingKey] copy];
		_comment = [[properties objectOrNilForKey:kCommentKey] copy];
		_fundsBalance = [NMAmount amountWithValue:[properties doubleValueOrZeroForKey:kFundsBalanceValueKey]
									 currencyCode:[properties objectOrNilForKey:kFundsBalanceCurrencyCodeKey]];
		_fundsHistoricAverage = [NMAmount amountWithValue:[properties doubleValueOrZeroForKey:kFundsHistoricAverageValueKey]
											 currencyCode:[properties objectOrNilForKey:kFundsHistoricAverageCurrencyCodeKey]];
		_fundsGraphData = [[properties objectOrNilForKey:kFundsGraphDataKey] copy];
	}
	
	return self;
}

#pragma mark - [ Properties ]

- (UIImage *)fundsGraph
{
	if (_fundsGraphImage == nil) {
		if (_fundsGraphData) {
			_fundsGraphImage = [UIImage imageWithData:_fundsGraphData];
		}
	}
	
	return _fundsGraphImage;
}

- (void)setFundsGraph:(UIImage *)image
{
	if (_fundsGraphImage != image) {
		_fundsGraphImage = image;
		_fundsGraphData = nil;
		
		if (_fundsGraphImage) {
			_fundsGraphData = UIImagePNGRepresentation(_fundsGraphImage);
		}
	}
}

#pragma mark - [ Properties (NMSerializing) ]

- (NSMutableDictionary *)properties
{
	NSMutableDictionary *properties = [super properties];
	[properties setObjectOrNil:[_date stringRFC3339] forKey:kDateKey];
	[properties setObjectOrNil:_heading forKey:kHeadingKey];
	[properties setObjectOrNil:_comment	forKey:kCommentKey];
	[properties setObjectOrNil:_fundsBalance.currencyCode forKey:kFundsBalanceCurrencyCodeKey];
	[properties setDoubleValue:_fundsBalance.value forKey:kFundsBalanceValueKey];
	[properties setObjectOrNil:_fundsHistoricAverage.currencyCode forKey:kFundsHistoricAverageCurrencyCodeKey];
	[properties setDoubleValue:_fundsHistoricAverage.value forKey:kFundsHistoricAverageValueKey];
	[properties setObjectOrNil:_fundsGraphData forKey:kFundsGraphDataKey];
	
	return properties;
}

@end
