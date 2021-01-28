//
//  NMFinancialGraphView.h
//  NoMo
//
//  Created by Costas Harizakis on 10/31/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@class NMFinancialGraphView;

@protocol NMFinacialGraphViewDataSource <NSObject>

- (NMAmount *)financialGraphView:(NMFinancialGraphView *)graphView balanceForDate:(NSDate *)date;
- (NMAmount *)financialGraphView:(NMFinancialGraphView *)graphView historicAverageForDate:(NSDate *)date;

@end


@interface NMFinancialGraphView : UIView

@property (nonatomic, strong) IBInspectable UIColor *balanceAboveHistoricAverageColor;
@property (nonatomic, strong) IBInspectable UIColor *balanceBelowHistoricAverageColor;
@property (nonatomic, strong) IBInspectable UIColor *balanceSameAsHistoricAverageColor;
@property (nonatomic, strong) IBInspectable UIColor *historicAverageColor;

@property (nonatomic, copy) NSString *currencyCode;
@property (nonatomic, copy) NSDate *earliestDate;
@property (nonatomic, copy) NSDate *latestDate;
@property (nonatomic, copy) NSString *caption;

@property (nonatomic, weak) IBOutlet id<NMFinacialGraphViewDataSource> dataSource;

- (void)reloadData;

@end
