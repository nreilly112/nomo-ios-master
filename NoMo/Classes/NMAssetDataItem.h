//
//  NMAssetDataItem.h
//  NoMo
//
//  Created by Costas Harizakis on 10/20/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMItem.h"


@interface NMAssetDataItem : NMItem

@property (nonatomic, copy) NSDate *date;
@property (nonatomic, assign) double balance;
@property (nonatomic, assign) double historicAverage;
@property (nonatomic, assign) double overdraft;
@property (nonatomic, assign) double availableBalance;
@property (nonatomic, assign) double totalBalance;

@end
