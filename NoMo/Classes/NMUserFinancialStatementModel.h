//
//  NMUserFinancialStatementModel.h
//  NoMo
//
//  Created by Costas Harizakis on 10/20/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoModel.h"
#import "NMAssetDataItem.h"


@interface NMUserFinancialStatementModel : NoMoModel <NoMoLoadModel>

- (NSDate *)issueDate;
- (NSArray *)assetNames;
- (NSDate *)earliestDateForBalanceOfAssetNamed:(NSString *)assetName;
- (NSDate *)latestDateForBalanceOfAssetNamed:(NSString *)assetName;
- (NSDate *)earliestDateForHistoricAverageOfAssetNamed:(NSString *)assetName;
- (NSDate *)latestDateForHistoricAverageOfAssetNamed:(NSString *)assetName;
- (NMAmount *)balanceOfAssetNamed:(NSString *)assetName onDate:(NSDate *)date;
- (NMAmount *)historicAverageOfAssetNamed:(NSString *)assetName onDate:(NSDate *)date;
- (NMAmount *)overdraftOfAssetNamed:(NSString *)assetName onDate:(NSDate *)date;
- (NMAmount *)availableBalanceOfAssetNamed:(NSString *)assetName onDate:(NSDate *)date;
- (NMAmount *)totalBalanceOfAssetNamed:(NSString *)assetName onDate:(NSDate *)date;

+ (instancetype)sharedModel;

@end


@interface NMUserFinancialStatementModel (Demonstration)

+ (instancetype)demonstrationModel;

@end
