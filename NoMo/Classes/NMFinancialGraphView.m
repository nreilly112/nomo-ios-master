//
//  NMFinancialGraphView.m
//  NoMo
//
//  Created by Costas Harizakis on 10/31/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMFinancialGraphView.h"
#import "NMGraphView.h"


@interface NMFinancialGraphView ()

@property (nonatomic, strong, readonly) UIColor *defaultBalanceAboveHistoricAverageColor;
@property (nonatomic, strong, readonly) UIColor *defaultBalanceBelowHistoricAverageColor;
@property (nonatomic, strong, readonly) UIColor *defaultBalanceSameAsHistoricAverageColor;
@property (nonatomic, strong, readonly) UIColor *defaultHistoricAverageColor;

@property (nonatomic, weak) NMGraphView *graphView;

- (void)setup;

@end


@implementation NMFinancialGraphView

#pragma mark - [ Initializers ]

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setup];
	}
	
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self setup];
}

- (void)setup
{
	NMGraphView *graphView = [[NMGraphView alloc] initWithFrame:self.bounds];
	[self addContentSubview:graphView];
	_graphView = graphView;
	
	_defaultBalanceAboveHistoricAverageColor = [UIColor colorWithRGB:0xfcee21];
	_defaultBalanceBelowHistoricAverageColor = [UIColor colorWithRGB:0xf87216];
	_defaultBalanceSameAsHistoricAverageColor = [UIColor colorWithRGB:0xffffff];
	_defaultHistoricAverageColor = [UIColor colorWithRGB:0x02415a];
}

#pragma mark - [ Properties ]

- (void)setEarliestDate:(NSDate *)earliestDate
{
	_earliestDate = earliestDate;
	_latestDate = [_latestDate laterDate:_earliestDate];
}

- (void)setLatestDate:(NSDate *)latestDate
{
	_latestDate = latestDate;
	_earliestDate = [_earliestDate earlierDate:_latestDate];
}

#pragma mark - [ Methods ]

- (void)reloadData
{
	NSDate *date = [NSDate date];
	NSDate *earliestDate = _earliestDate ?: _latestDate ?: date;
	NSDate *latestDate = _latestDate ?: _earliestDate ?: date;
	
	NSDate *startDate = [earliestDate dateByAddingDays:-1];
	NSDate *endDate = [latestDate dateByAddingDays:+1];
	NSInteger numberOfDays = [endDate numberOfDaysSinceDate:startDate] + 1;
	
	NSArray *balanceValues = [self balanceValuesWithStartDate:startDate numberOfDays:numberOfDays];
	NSArray *historicAverageValues = [self historicAverageValuesWithStartDate:startDate numberOfDays:numberOfDays];
	NSArray *weekdayColors = [self weekdayColorsWithBalanceValues:balanceValues andHistoricAverageValues:historicAverageValues];

	NSRange balanceValuesRange = [self firstNonNilRangeInArray:balanceValues];
	NSRange historicAverageValuesRange = [self firstNonNilRangeInArray:historicAverageValues];

	NSInteger numberOfDaysDisplayed = numberOfDays - 2;

	_graphView.horizontalAxis.numberOfTicks = numberOfDaysDisplayed;

	for (NSUInteger index = 0; index < numberOfDaysDisplayed; index += 1) {
		id<NMGraphTick> tick = [_graphView.horizontalAxis tickAtIndex:index];
		NSDate *date = [earliestDate dateByAddingDays:index];
		UIColor *color = [weekdayColors objectOrNilAtIndex:index + 1];
		
		tick.text = (numberOfDays <= 7) ? [date shortWeekdayString] : [date veryShortWeekdayString];
		tick.color = color ?: [UIColor colorWithRGB:0x808080];
	}
	
	balanceValues = [balanceValues subarrayWithRange:balanceValuesRange];
	historicAverageValues = [historicAverageValues subarrayWithRange:historicAverageValuesRange];
	
	[_graphView.plotArea removeAllPlots];
	
	id<NMGraphPlot> plot1 = [_graphView.plotArea addPlotWithStyle:NMGraphPlotStyleGradient];
	plot1.color = _historicAverageColor ?: _defaultHistoricAverageColor;
	plot1.values = historicAverageValues;
	plot1.offset = historicAverageValuesRange.location - 1;
	
	id<NMGraphPlot> plot2 = [_graphView.plotArea addPlotWithStyle:NMGraphPlotStyleLine];
	plot2.color = [weekdayColors objectOrNilAtIndex:balanceValuesRange.location + balanceValuesRange.length - 1] ?: [UIColor whiteColor];
	plot2.values = balanceValues;
	plot2.offset = balanceValuesRange.location - 1;
	
	_graphView.verticalAxis.minimumValue = MIN(0.0, MIN([historicAverageValues minimumDoubleValue], [balanceValues minimumDoubleValue]));
	_graphView.verticalAxis.maximumValue = MAX(0.0, MAX([historicAverageValues maximumDoubleValue], [balanceValues maximumDoubleValue]));
	_graphView.verticalAxis.preferredNumberOfGridlines = 5;
	
	for (id<NMGraphGridline> gridline in _graphView.verticalAxis.gridlines) {
		NMAmount *amount = [NMAmount amountWithValue:gridline.offset currencyCode:_currencyCode];
		gridline.text = [NSString stringForAmount:amount];
		gridline.color = [UIColor whiteColor];
	}
	
	_graphView.caption = _caption;
}

#pragma mark - [ Private Methods ]

- (NSMutableArray *)weekdayColorsWithBalanceValues:(NSArray *)balanceValues andHistoricAverageValues:(NSArray *)historicAverageValues
{
	NSUInteger count = MAX(balanceValues.count, historicAverageValues.count);
	NSMutableArray *colors = [NSMutableArray arrayWithCapacity:count];
	
	for (NSUInteger index = 0; index < count; index += 1) {
		NSNumber *balanceValue = [balanceValues objectOrNilAtIndex:index];
		NSNumber *historicAverageValue = [historicAverageValues objectOrNilAtIndex:index];
		UIColor *color = nil;
		
		if (balanceValue && historicAverageValue) {
			if ([balanceValue compare:historicAverageValue] < 0) {
				color = _balanceBelowHistoricAverageColor ?: _defaultBalanceBelowHistoricAverageColor;
			}
			else if ([historicAverageValue compare:balanceValue] < 0) {
				color = _balanceAboveHistoricAverageColor ?: _defaultBalanceAboveHistoricAverageColor;
			}
			else {
				color = _balanceSameAsHistoricAverageColor ?: _defaultBalanceSameAsHistoricAverageColor;
			}
		}
		
		[colors addObjectOrNil:color];
	}
	
	return colors;
}

- (NSMutableArray *)balanceValuesWithStartDate:(NSDate *)startDate numberOfDays:(NSInteger)count
{
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:count];
	
	for (NSInteger index = 0; index < count; index += 1) {
		NSDate *date = [startDate dateByAddingDays:index];
		NMAmount *amount = [_dataSource financialGraphView:self balanceForDate:date];
		
		if (amount && [_currencyCode isEqualToString:amount.currencyCode]) {
			[values addObject:@(amount.value)];
		}
		else {
			[values addObject:[NSNull null]];
		}
	}
	
	return values;
}

- (NSMutableArray *)historicAverageValuesWithStartDate:(NSDate *)startDate numberOfDays:(NSInteger)count
{
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:count];
	
	for (NSInteger index = 0; index < count; index += 1) {
		NSDate *date = [startDate dateByAddingDays:index];
		NMAmount *amount = [_dataSource financialGraphView:self historicAverageForDate:date];
		
		if (amount && [_currencyCode isEqualToString:amount.currencyCode]) {
			[values addObject:@(amount.value)];
		}
		else {
			[values addObject:[NSNull null]];
		}
	}
	
	return values;
}

- (NSRange)firstNonNilRangeInArray:(NSArray *)array
{
	NSUInteger startIndex = [array indexOfFirstNonNilValue];
	
	if (startIndex != NSNotFound) {
		NSUInteger endIndex = [array indexOfFirstNilValueAfterIndex:startIndex];
		
		if (endIndex == NSNotFound) {
			endIndex = array.count;
		}

		return NSMakeRange(startIndex, endIndex - startIndex);
	}
	
	return NSMakeRange(0, 0);
}

@end
