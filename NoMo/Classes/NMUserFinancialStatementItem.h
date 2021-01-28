//
//  NMUserFinancialStatementItem.h
//  NoMo
//
//  Created by Costas Harizakis on 10/20/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMItem.h"
#import "NMAssetDataItem.h"


extern NSString * const kAssetNameBankAccount;
extern NSString * const kAssetNameFunds;


@interface NMUserFinancialStatementItem : NMItem

@property (nonatomic, copy, readonly) NSDate *issueDate;
@property (nonatomic, copy, readonly) NSString *currency;
@property (nonatomic, copy, readonly) NSDictionary *assets;

- (NSArray *)assetNames;
- (NSArray *)allDataForAssetNamed:(NSString *)assetName; // Array of NMAssetDataItem objects.
- (NMAssetDataItem *)dataForAssetNamed:(NSString *)assetName onDate:(NSDate *)date;

@end


@interface NMUserFinancialStatementItem (Common)

- (NSArray *)allDataForBankAccount;
- (NSArray *)allDataForFunds;

@end


