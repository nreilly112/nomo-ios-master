//
//  NMAssetDataItem.m
//  NoMo
//
//  Created by Costas Harizakis on 10/20/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMAssetDataItem.h"


#define kDateKey @"date"
#define kHistoricAverageKey @"average"
#define kBalanceKey @"balance"
#define kAvailableBalanceKey @"availableBalance"
#define kOverdraftKey @"overdraft"
#define kTotalBalanceKey @"totalBalance"


@implementation NMAssetDataItem

#pragma mark - [ Initializer ]

- (instancetype)initWithProperties:(NSDictionary *)properties
{
	self = [super initWithProperties:properties];
	
	if (self) {
		_date = [[properties dateOrNilForKey:kDateKey] copy];
        id balance = [properties objectOrNilForKey:kBalanceKey];
        id historicAverage = [properties objectOrNilForKey:kHistoricAverageKey];
        id totalBalance = [properties objectOrNilForKey:kTotalBalanceKey];
        id availableBalance = [properties objectOrNilForKey:kAvailableBalanceKey];
        id overdraft = [properties objectOrNilForKey:kOverdraftKey];
        if (balance == nil) {
            _balance = NAN;
        } else {
            _balance = [balance doubleValue];
        }
        if (historicAverage == nil) {
            _historicAverage = NAN;
        } else {
            _historicAverage = [historicAverage doubleValue];
        }
        if (totalBalance == nil) {
            _totalBalance = NAN;
        } else {
            _totalBalance = [totalBalance doubleValue];
        }
        if (availableBalance == nil) {
            _availableBalance = NAN;
        } else {
            _availableBalance = [availableBalance doubleValue];
        }
        if (overdraft == nil) {
            _overdraft = NAN;
        } else {
            _overdraft = [overdraft doubleValue];
        }
	}
	
	return self;
}

#pragma mark - [ Properties ]

- (NSMutableDictionary *)properties
{
	NSMutableDictionary *properties = [super properties];
	
	[properties setObjectOrNil:[_date stringRFC3339] forKey:kDateKey];

	if (!isnan(_balance)) {
		[properties setDoubleValue:_balance forKey:kBalanceKey];
	}
	if (!isnan(_historicAverage)) {
		[properties setDoubleValue:_historicAverage forKey:kHistoricAverageKey];
	}
    if (!isnan(_availableBalance)) {
        [properties setDoubleValue:_availableBalance forKey:kAvailableBalanceKey];
    }
    if (!isnan(_totalBalance)) {
        [properties setDoubleValue:_totalBalance forKey:kTotalBalanceKey];
    }
    if (!isnan(_overdraft)) {
        [properties setDoubleValue:_overdraft forKey:kOverdraftKey];
    }

	return properties;
}

@end
