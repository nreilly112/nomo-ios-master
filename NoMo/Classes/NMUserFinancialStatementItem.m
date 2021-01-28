//
//  NMUserFinancialStatementItem.m
//  NoMo
//
//  Created by Costas Harizakis on 10/20/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMUserFinancialStatementItem.h"


#define kIssueDateKey @"issueDate"
#define kCurrencyKey @"currency"
#define kAssetsKey @"assets"


NSString * const kAssetNameBankAccount = @"bankAccount";
NSString * const kAssetNameFunds = @"funds";


@implementation NMUserFinancialStatementItem

#pragma mark - [ Initializers ]

- (instancetype)initWithProperties:(NSDictionary *)properties
{
	self = [super initWithProperties:properties];
	
	if (self) {
		_issueDate = [[properties dateOrNilForKey:kIssueDateKey] copy];
		_currency = [[properties objectOrNilForKey:kCurrencyKey] copy];
		_assets = [[properties objectOrNilForKey:kAssetsKey] dictionaryByConvertingPropertiesToItemsOfKind:[NMAssetDataItem class]];
		
		// NOTE: No need to set/adjust dates; they are now part of the response.
		// --harizak (2016-11-15)
		// [self updateAssetDataDates];
	}
	
	return self;
}

#pragma mark - [ Properties ]

- (NSMutableDictionary *)properties
{
	NSMutableDictionary *properties = [super properties];
	[properties setObjectOrNil:[_issueDate stringRFC3339] forKey:kIssueDateKey];
	[properties setObjectOrNil:_currency forKey:kCurrencyKey];
	[properties setObjectOrNil:[_assets dictionaryByConvertingItemsToProperties] forKey:kAssetsKey];
	
	return properties;
}

#pragma mark - [ Methods ]

- (NSArray *)assetNames
{
	return [_assets allKeys];
}

- (NSArray *)allDataForAssetNamed:(NSString *)assetName
{
	return [_assets objectOrNilForKey:assetName];
}

- (NMAssetDataItem *)dataForAssetNamed:(NSString *)assetName onDate:(NSDate *)date
{
	NSArray * items = [_assets objectOrNilForKey:assetName];
	
	for (NMAssetDataItem *item in items) {
		if ([date isSameDayWithDate:item.date]) {
			return item;
		}
	}
	
	return nil;
}

#pragma mark - [ Private Methods ]

- (void)updateAssetDataDates
{
	for (NSString *assetName in _assets) {
		NSArray *arrayOfAssetData = [_assets objectForKey:assetName];
		NSDate *assetDate = _issueDate;
	
		for (NMAssetDataItem *assetData in arrayOfAssetData) {
			assetData.date = assetDate;
			assetDate = [assetDate dateByAddingDays:-1];
		}
	}
}

@end


@implementation NMUserFinancialStatementItem (Common)

- (NSArray *)allDataForBankAccount
{
	return [self allDataForAssetNamed:kAssetNameBankAccount];
}

- (NSArray *)allDataForFunds
{
	return [self allDataForAssetNamed:kAssetNameFunds];
}

@end
