//
//  NMGraphView.m
//  NoMo
//
//  Created by Costas Harizakis on 10/27/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMGraphView.h"


@interface NMGraphPlotView : UIView <NMGraphPlot>

@property (nonatomic, assign) NMGraphPlotStyle style;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, copy) NSArray *values;
@property (nonatomic, assign) NSInteger offset;

- (instancetype)initWithStyle:(NMGraphPlotStyle)style;

@end


@interface NMGraphPlotAreaView : UIView <NMGraphPlotArea>

@property (nonatomic, assign, readonly) NSUInteger numberOfPlots;

- (NMGraphPlotView *)addPlotWithStyle:(NMGraphPlotStyle)style;
- (NMGraphPlotView *)plotAtIndex:(NSUInteger)index;
- (void)removePlotAtIndex:(NSUInteger)index;
- (void)removeAllPlots;

@end


@interface NMGraphTickView : UIView <NMGraphTick>

@property (nonatomic, assign, readonly) NSUInteger index;
@property (nonatomic, weak) UILabel *label;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIColor *color;

- (instancetype)initWithIndex:(NSUInteger)index;

@end


@interface NMGraphGridlineView : UIView <NMGraphGridline>

@property (nonatomic, assign, readonly) double offset;
@property (nonatomic, weak) UILabel *label;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIColor *color;

- (instancetype)initWithOffset:(double)offset;

@end


@interface NMGraphVerticalAxisView : UIView <NMGraphVerticalAxis>

@property (nonatomic, assign) double minimumValue;
@property (nonatomic, assign) double maximumValue;
@property (nonatomic, assign) NSUInteger preferredNumberOfGridlines;

@property (nonatomic, assign, readonly) double adjustedMinimumValue;
@property (nonatomic, assign, readonly) double adjustedMaximumValue;
@property (nonatomic, assign, readonly) double gridlineSpacing;

@property (nonatomic, copy, readonly) NSArray *gridlineOffsets;

- (id<NMGraphGridline>)gridlineAtOffset:(double)offset;

@end


@interface NMGraphHorizontalAxisView : UIView <NMGraphHorizontalAxis>

@property (nonatomic, assign) NSUInteger numberOfTicks;

- (id<NMGraphTick>)tickAtIndex:(NSUInteger)index;
- (void)addTickViewWithIndex:(NSUInteger)index;
- (void)removeLastTickView;

@end


@interface NMGraphView ()

@property (nonatomic, weak) IBOutlet NMGraphPlotAreaView *plotAreaView;
@property (nonatomic, weak) IBOutlet NMGraphVerticalAxisView *verticalAxisView;
@property (nonatomic, weak) IBOutlet NMGraphHorizontalAxisView *horizontalAxisView;
@property (nonatomic, weak) IBOutlet UILabel *captionLabel;
@property (nonatomic, weak) IBOutlet UIView *captionContainer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *captionContainerHeight;

- (CGPoint)pointForValue:(double)value atIndex:(NSInteger)index;

@end


@implementation NMGraphView

#pragma mark - [ Initializers ]

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self) {
		[self addContentSubview:[self contentViewFromNib]];		
	}
	
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self addContentSubview:[self contentViewFromNib]];
}

#pragma mark - [ Properties ]

- (id<NMGraphPlotArea>)plotArea
{
	return _plotAreaView;
}

- (id<NMGraphHorizontalAxis>)horizontalAxis
{
	return _horizontalAxisView;
}

- (id<NMGraphVerticalAxis>)verticalAxis
{
	return _verticalAxisView;
}

- (NSString *)caption
{
	return _captionLabel.text;
}

- (void)setCaption:(NSString *)caption
{
	_captionLabel.text = caption;
	_captionContainerHeight.constant = (caption) ? _captionLabel.height : 0.0;
	[_captionContainer setNeedsUpdateConstraints];
}

#pragma mark - [ Private Methods ]

- (CGPoint)pointForValue:(double)value atIndex:(NSInteger)index
{
	CGSize size = _plotAreaView.size;
	CGFloat numberOfTicks = _horizontalAxisView.numberOfTicks;
	double minValue = _verticalAxisView.adjustedMinimumValue;
	double maxValue = _verticalAxisView.adjustedMaximumValue;
	
	if (maxValue <= minValue) {
		return CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);
	}
	if (numberOfTicks == 0) {
		return CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);
	}
	
	CGFloat widthPerTick = size.width / numberOfTicks;
	CGFloat x = index * widthPerTick + 0.5 * widthPerTick;
	CGFloat y = size.height - size.height * (value - minValue) / (maxValue - minValue);
	
	return CGPointMake(x, y);
}

@end


@implementation NMGraphPlotView

#pragma mark - [ Initializers ]

- (instancetype)initWithStyle:(NMGraphPlotStyle)style
{
	self = [super initWithFrame:CGRectZero];
	
	if (self) {
		_style = style;
		_values = nil;
		_offset = 0;
		
		self.backgroundColor = [UIColor clearColor];
	}
	
	return self;
}

#pragma mark - [ UIView Methods ]

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	
	if (_values.count == 0) {
		return;
	}
	
	NMGraphView *graph = (NMGraphView *)[self ancestorOrSelfWithClass:[NMGraphView class]];
	
	CGPoint (^pointForValueAtIndex)(NSInteger) = ^(NSInteger index) {
		double value = [[self.values objectOrNilAtIndex:index] doubleValue];
		return [graph pointForValue:value atIndex:self.offset + index];
	};

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);

	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextSetAllowsAntialiasing(context, YES);
	CGContextSetShouldAntialias(context, YES);
	CGContextSetMiterLimit(context, 2.0);
	
	CGContextBeginPath(context);
	
	CGPoint point = pointForValueAtIndex(0);
	
	CGContextMoveToPoint(context, point.x, point.y);
	
	for (NSInteger index = 1; index < _values.count; index += 1) {
		CGPoint nextPoint = pointForValueAtIndex(index);
#if 0
		//CGContextAddLineToPoint(context, nextPoint.x, nextPoint.y);
#else
		CGPoint midPoint = CGPointGetMidPoint(point, nextPoint);
		CGPoint controlPoint1 = [self controlPointBetweenPoint1:midPoint andPoint2:point];
		CGContextAddQuadCurveToPoint(context, controlPoint1.x, controlPoint1.y, midPoint.x, midPoint.y);
		CGPoint controlPoint2 = [self controlPointBetweenPoint1:midPoint andPoint2:nextPoint];
		CGContextAddQuadCurveToPoint(context, controlPoint2.x, controlPoint2.y, nextPoint.x, nextPoint.y);
#endif
		point = nextPoint;
	}

	CGPoint startPoint = [graph pointForValue:0.0 atIndex:_offset];
	CGPoint endPoint = [graph pointForValue:0.0 atIndex:_offset + _values.count - 1];
	
	UIColor *color = _color ?: [UIColor whiteColor];
	[color setStroke];
	[color setFill];
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

	UIColor *gradientStartColor = color;
	UIColor *gradientEndColor = [color colorWithHalfBrightnessComponent];
	NSArray *gradientColors = @[ (id)gradientStartColor.CGColor, (id)gradientEndColor.CGColor ];
	CGPoint gradientStartPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
	CGPoint gradientEndPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));

	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, NULL);
	
	switch (_style) {
		case NMGraphPlotStyleDefault:
		case NMGraphPlotStyleLine:
			CGContextSetLineWidth(context, 3.0);
			CGContextDrawPath(context, kCGPathStroke);
			break;
		case NMGraphPlotStyleFilled:
			CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
			CGContextAddLineToPoint(context, startPoint.x, startPoint.y);
			CGContextClosePath(context);
			CGContextDrawPath(context, kCGPathFill);
			break;
		case NMGraphPlotStyleGradient:
			CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
			CGContextAddLineToPoint(context, startPoint.x, startPoint.y);
			CGContextClosePath(context);
			CGContextClip(context);
			CGContextDrawLinearGradient(context, gradient, gradientStartPoint, gradientEndPoint, 0);
			break;
	}
	
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);

	CGContextRestoreGState(context);
}

#pragma mark - [ Privage Methods ]

- (CGPoint)controlPointBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2
{
	CGPoint controlPoint = CGPointGetMidPoint(point1, point2);
	CGFloat diffY = abs((int) (point2.y - controlPoint.y));
	
	if (point1.y < point2.y) {
		controlPoint.y += diffY;
	}
	else if (point2.y < point1.y) {
		controlPoint.y -= diffY;
	}
	
	return controlPoint;
}

@end


@implementation NMGraphPlotAreaView

#pragma mark - [ Properties ]

- (NSUInteger)numberOfPlots
{
	return self.subviews.count;
}

#pragma mark - [ Methods ]

- (NMGraphPlotView *)addPlotWithStyle:(NMGraphPlotStyle)style
{
	NMGraphPlotView *plotView = [[NMGraphPlotView alloc] initWithStyle:style];
	plotView.frame = self.bounds;
	plotView.autoresizingMask = UIViewAutoresizingFlexibleSize;
	[self addSubview:plotView];
	
	return plotView;
}

- (NMGraphPlotView *)plotAtIndex:(NSUInteger)index
{
	return [self.subviews objectOrNilAtIndex:index];
}

- (void)removePlotAtIndex:(NSUInteger)index
{
	NMGraphPlotView *plotView = [self plotAtIndex:index];
	[plotView removeFromSuperview];
}

- (void)removeAllPlots
{
	[self removeAllSubviews];
}

#pragma mark - [ UIView Methods ]

- (void)addSubview:(UIView *)view
{
	NSAssert([view isKindOfClass:[NMGraphPlotView class]], @"Only plot views are allowed.");
	[super addSubview:view];
}

@end


@implementation NMGraphGridlineView

#pragma mark - [ Initializer ]

- (instancetype)initWithOffset:(double)offset
{
	self = [super initWithFrame:CGRectZero];
	
	if (self) {
		UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
		label.backgroundColor = [UIColor colorWithRGB:0x000000 alpha:0.5];
		label.cornerRadius = 3.0;
		label.font = [UIFont fontWithName:@"Montserrat-Regular" size:9.0];
		label.textColor = [UIColor whiteColor];
		label.textAlignment = NSTextAlignmentCenter;
		label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
		[self addSubview:label];
		
		_offset = offset;
		_label = label;
		
		self.alpha = 0.5;
		self.backgroundColor = [UIColor clearColor];
	}
	
	return self;
}

#pragma mark - [ Properties ]

- (NSString *)text
{
	return _label.text;
}

- (void)setText:(NSString *)text
{
	_label.text = text;
	[self setNeedsLayout];
}

- (UIColor *)color
{
	return _label.textColor;
}

- (void)setColor:(UIColor *)color
{
	_label.textColor = color;
	[self setNeedsDisplay];
}

#pragma mark - [ UIView Methods ]

- (CGSize)sizeThatFits:(CGSize)size
{
	return CGSizeMake(self.superview.width, 1.0);
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[_label sizeToFit];

	_label.right = self.width;
	
	if ((self.centerY + _label.height) <= self.superview.height) {
		_label.top = 0.5 * self.height;
	}
	else {
		_label.bottom = 0.5 * self.height;
	}

}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 0.0, 0.5 * self.height);
	CGContextAddLineToPoint(context, self.width, 0.5 * self.height);

	CGFloat dashLengths[] = { 5.0, 4.0 };
	
	CGContextSetLineWidth(context, 0.5);
	CGContextSetLineDash(context, 0.0, dashLengths, 2);

	[[_label.textColor colorWithAlphaComponent:0.4] set];

	CGContextDrawPath(context, kCGPathStroke);

	CGContextRestoreGState(context);
}

@end


@implementation NMGraphVerticalAxisView

#pragma mark - [ Properties ]

- (void)setMinimumValue:(double)minimumValue
{
	if (_minimumValue != minimumValue) {
		_minimumValue = minimumValue;
		[self updateAxis];
	}
}

- (void)setMaximumValue:(double)maximumValue
{
	if (_maximumValue != maximumValue) {
		_maximumValue = maximumValue;
		[self updateAxis];
	}
}

- (void)setPreferredNumberOfGridlines:(NSUInteger)preferredNumberOfGridlines
{
	if (_preferredNumberOfGridlines != preferredNumberOfGridlines) {
		_preferredNumberOfGridlines = preferredNumberOfGridlines;
		[self updateAxis];
	}
}

- (NSArray *)gridlineOffsets
{
	NSArray *gridlineViews = self.subviews;
	NSMutableArray *gridlineOffsets = [NSMutableArray arrayWithCapacity:gridlineViews.count];
	
	for (NMGraphGridlineView *gridlineView in gridlineViews) {
		[gridlineOffsets addObject:@(gridlineView.offset)];
	}
	
	return gridlineOffsets;
}

- (NSArray *)gridlines
{
	return self.subviews;
}

#pragma mark - [ Methods ]

- (NMGraphGridlineView *)gridlineAtOffset:(double)offset
{
	for (NMGraphGridlineView *gridlineView in self.subviews) {
		if (gridlineView.offset == offset) {
			return gridlineView;
		}
	}
	
	return nil;
}

#pragma mark - [ UIView Methods ]

- (void)addSubview:(UIView *)view
{
	NSAssert([view isKindOfClass:[NMGraphGridlineView class]], @"Only gridline views are allowed.");
	[super addSubview:view];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	NMGraphView *graph = (NMGraphView *)[self ancestorOrSelfWithClass:[NMGraphView class]];
	
	for (NMGraphGridlineView *gridlineView in self.subviews) {
		CGPoint point = [graph pointForValue:gridlineView.offset atIndex:0];
		CGFloat offsetY = point.y;

		[gridlineView sizeToFit];
		[gridlineView setCenterY:offsetY];
	}
}

#pragma mark - [ Private Methods ]

- (void)addGridlineViewAtOffset:(double)offset
{
	NMGraphGridlineView *gridlineView = [[NMGraphGridlineView alloc] initWithOffset:offset];
	[self addSubview:gridlineView];
}

- (void)updateAxis
{
	double range = _maximumValue - _minimumValue;
	double adjustedRange = [self closestNumberToValue:range rounded:NO];

	NSUInteger numberOfGridlines = MAX(_preferredNumberOfGridlines, 2);
	
	_gridlineSpacing = [self closestNumberToValue:(adjustedRange / (numberOfGridlines - 1)) rounded:YES];
	_adjustedMinimumValue = 1.1 * floor(_minimumValue / _gridlineSpacing) * _gridlineSpacing;
	_adjustedMaximumValue = 1.1 * ceil(_maximumValue / _gridlineSpacing) * _gridlineSpacing;
	
	[self updateGridlines];
	[self.superview setNeedsLayout];
}

- (void)updateGridlines
{
	[self removeAllSubviews];
	
	for (double offset = _adjustedMinimumValue; offset <= _adjustedMaximumValue; offset += _gridlineSpacing) {
		[self addGridlineViewAtOffset:offset];
	}
	
	[self setNeedsLayout];
}

- (double)closestNumberToValue:(double)value rounded:(BOOL)rounded
{
	double exponent = floor(log10(value));
	double roundedValue = pow(10.0, exponent);
	double fraction = value / roundedValue;
	
	if (rounded) {
		if (fraction < 1.5) {
			fraction = 1.0;
		}
		else if (fraction < 3.0) {
			fraction = 2.0;
		}
		else if (fraction < 7.5) {
			fraction = 5.0;
		}
		else {
			fraction = 10.0;
		}
	}
	else {
		if (fraction <= 1.0) {
			fraction = 1.0;
		}
		else if (fraction <= 2.0) {
			fraction = 2.0;
		}
		else if (fraction <= 5.0) {
			fraction = 5.0;
		}
		else {
			fraction = 10.0;
		}
	}
	
	return fraction * roundedValue;
}

@end



@implementation NMGraphTickView

#pragma mark - [ Initializer ]

- (instancetype)initWithIndex:(NSUInteger)index
{
	self = [super initWithFrame:CGRectZero];
	
	if (self) {
		UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
		label.font = [UIFont fontWithName:@"Montserrat-Regular" size:9.0];
		label.textColor = [UIColor whiteColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addContentSubview:label];

		_index = index;
		_label = label;
	}
	
	return self;
}

#pragma mark - [ Properties ]

- (void)setText:(NSString *)text
{
	_label.text = text;
}

- (NSString *)text
{
	return _label.text;
}

- (void)setColor:(UIColor *)color
{
	_label.textColor = color;
}

- (UIColor *)color
{
	return _label.textColor;
}

@end


@implementation NMGraphHorizontalAxisView

#pragma mark - [ Properties ]

- (NSUInteger)numberOfTicks
{
	return self.subviews.count;
}

- (void)setNumberOfTicks:(NSUInteger)numberOfTicks
{
	while (numberOfTicks < self.subviews.count) {
		[self removeLastTickView];
	}
	while (self.subviews.count < numberOfTicks) {
		[self addTickViewWithIndex:self.subviews.count];
	}
}

- (NSArray *)ticks
{
	return self.subviews;
}

#pragma mark - [ Methods ]

- (NMGraphTickView *)tickAtIndex:(NSUInteger)index
{
	return [self.subviews objectOrNilAtIndex:index];
}

#pragma mark - [ UIView ]

- (void)addSubview:(UIView *)view
{
	NSAssert([view isKindOfClass:[NMGraphTickView class]], @"Only tick views are allowed.");
	[super addSubview:view];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	NSArray *views = self.subviews;
	NSUInteger count = views.count;
	
	if (0 < count) {
		CGFloat width = self.width / count;
		CGFloat height = self.height;
		CGRect frame = CGRectMake(0.0, 0.0, width, height);
		
		for (UIView *view in views) {
			view.frame = frame;
			frame = CGRectOffset(frame, width, 0.0);
		}
	}
}

#pragma mark - [ Private Methods ]

- (void)addTickViewWithIndex:(NSUInteger)index
{
	NMGraphTickView *tickView = [[NMGraphTickView alloc] initWithIndex:index];
	[self addSubview:tickView];
	[self setNeedsLayout];
}

- (void)removeLastTickView
{
	NMGraphTickView *tickView = [self.subviews lastObjectOrNil];
	[tickView removeFromSuperview];
}

@end

