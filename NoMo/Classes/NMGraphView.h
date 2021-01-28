//
//  NMGraphView.h
//  NoMo
//
//  Created by Costas Harizakis on 10/27/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


typedef NS_ENUM(NSInteger, NMGraphPlotStyle) {
	NMGraphPlotStyleDefault = 0,
	NMGraphPlotStyleLine = 1,
	NMGraphPlotStyleFilled = 2,
	NMGraphPlotStyleGradient = 3
};


@protocol NMGraphPlot <NSObject>

@property (nonatomic, assign) NMGraphPlotStyle style;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, copy) NSArray *values;
@property (nonatomic, assign) NSInteger offset;

@end


@protocol NMGraphPlotArea <NSObject>

@property (nonatomic, assign, readonly) NSUInteger numberOfPlots;

- (id<NMGraphPlot>)addPlotWithStyle:(NMGraphPlotStyle)style;
- (id<NMGraphPlot>)plotAtIndex:(NSUInteger)index;
- (void)removePlotAtIndex:(NSUInteger)index;
- (void)removeAllPlots;

@end


@protocol NMGraphGridline <NSObject>

@property (nonatomic, assign, readonly) double offset;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIColor *color;

@end


@protocol NMGraphVerticalAxis <NSObject>

@property (nonatomic, assign) double minimumValue;
@property (nonatomic, assign) double maximumValue;
@property (nonatomic, assign) NSUInteger preferredNumberOfGridlines;

@property (nonatomic, copy, readonly) NSArray *gridlineOffsets;
@property (nonatomic, strong, readonly) NSArray<id<NMGraphGridline>> *gridlines;

- (id<NMGraphGridline>)gridlineAtOffset:(double)offset;

@end


@protocol NMGraphTick <NSObject>

@property (nonatomic, assign, readonly) NSUInteger index;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIColor *color;

@end


@protocol NMGraphHorizontalAxis <NSObject>

@property (nonatomic, assign) NSUInteger numberOfTicks;
@property (nonatomic, strong, readonly) NSArray<id<NMGraphTick>> *ticks;

- (id<NMGraphTick>)tickAtIndex:(NSUInteger)index;

@end


@interface NMGraphView : UIView

@property (nonatomic, strong, readonly) id<NMGraphPlotArea> plotArea;
@property (nonatomic, strong, readonly) id<NMGraphHorizontalAxis> horizontalAxis;
@property (nonatomic, strong, readonly) id<NMGraphVerticalAxis> verticalAxis;
@property (nonatomic, copy) NSString *caption;

@end
