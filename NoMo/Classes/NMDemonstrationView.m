//
//  NMDemonstrationView.m
//  NoMo
//
//  Created by Costas Harizakis on 15/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMDemonstrationView.h"


@interface NMDemonstrationView ()

@property (nonatomic, weak) IBOutlet UIView *annotationBackgroundView;
@property (nonatomic, weak) IBOutlet UIView *annotationBorderView;
@property (nonatomic, weak) IBOutlet UILabel *annotationLabel;

@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) CGFloat shadowAlpha;

@end


@implementation NMDemonstrationView

#pragma mark - [ Initializers ]

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self addContentSubview:[self contentViewFromNib]];
	[self updateState];

	self.backgroundColor = [UIColor clearColor];
	
	_shadowColor = [UIColor colorWithRGB:0x000000];
	_shadowAlpha = 0.7;
	
	_annotationBackgroundView.backgroundColor = _shadowColor;
	
}

#pragma mark - [ Properties ]

- (void)setAnnotatedView:(NMAnnotatedView *)annotatedView
{
	[self setAnnotatedView:annotatedView animated:NO];
}

#pragma mark - [ Methods ]

- (void)setAnnotatedView:(NMAnnotatedView *)annotatedView animated:(BOOL)animated
{
	void (^hideAnimation)(void) = ^(void) {
		_annotationBackgroundView.alpha = _shadowAlpha;
		_annotationBorderView.alpha = 0.0;
		_annotationLabel.alpha = 0.0;
	};
	void (^hideCompleted)(void) = ^(void) {
		_annotationBorderView.hidden = YES;
		[self.layer setNeedsDisplay];
		[self.layer displayIfNeeded];
	};
	void (^showSetup)(void) = ^(void) {
		[self updateState];
		_annotationBorderView.hidden = NO;
		_annotationBackgroundView.alpha = _shadowAlpha;
		_annotationBorderView.alpha = 0.0;
		[self.layer setNeedsDisplay];
		[self.layer displayIfNeeded];
	};
	void (^showAnimation)(void) = ^(void) {
		_annotationBackgroundView.alpha = 0.0;
		_annotationBorderView.alpha = 1.0;
		_annotationLabel.alpha = 1.0;
	};
	void (^showCompleted)(void) = ^(void) {
	};
	void (^showIfNeeded)(void) = ^(void) {
		if (_annotatedView) {
			showSetup();
			[UIView animateWithDuration:0.25 animations:^(void) {
				showAnimation();
			} completion:^(BOOL finished) {
				showCompleted();
			}];
		}
	};

	if (_annotatedView != annotatedView) {
		_annotatedView = annotatedView;

		if (animated) {
			if (!_annotationBorderView.hidden) {
				[UIView animateWithDuration:0.25 animations:^(void) {
					hideAnimation();
				} completion:^(BOOL finished) {
					hideCompleted();
					showIfNeeded();
				}];
			}
			else {
				showIfNeeded();
			}
		}
		else {
			if (!_annotationBorderView.hidden) {
				hideAnimation();
				hideCompleted();
			}
			if (_annotatedView) {
				showSetup();
				showAnimation();
				showCompleted();
			}
		}
	}
}

#pragma mark - [ UIView Methods ]

- (void)layoutSubviews
{
	[super layoutSubviews];

	[self updateViewPositions];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);

	CGContextClearRect(context, self.bounds);
	
	CGContextSetAlpha(context, _shadowAlpha);
	CGContextSetFillColorWithColor(context, _shadowColor.CGColor);

	CGContextBeginPath(context);
	CGContextAddRect(context, self.bounds);
	
	if (!_annotationBorderView.hidden) {
		CGContextAddRect(context, _annotationBorderView.frame);
	}
	
	CGContextDrawPath(context, kCGPathEOFill);
	
	CGContextRestoreGState(context);
}

#pragma mark - [ Private Methods ]

- (void)updateState
{
	_annotationLabel.text = _annotatedView.annotationText;
	_annotationLabel.hidden = (_annotatedView == nil);
	_annotationBorderView.hidden = (_annotatedView == nil);
	
	[self updateViewPositions];
}

- (void)updateViewPositions
{
	const CGFloat padding = 50.0;
	const CGFloat distance = 35.0;
	
	CGRect rect = [self frameForAnnotatedView];
	
	CGSize preferredLabelSize = CGSizeMake(0.5 * self.width, 0.0);
	CGSize actualLabelSize = [_annotationLabel systemLayoutSizeFittingSize:preferredLabelSize];
	
	_annotationBackgroundView.frame = rect;
	_annotationBorderView.frame = rect;
	_annotationLabel.size = actualLabelSize;
	_annotationLabel.left = _annotationBorderView.left;
	
	// Horizontal alignment.
	
	if (_annotationLabel.left < padding) {
		_annotationLabel.left = padding;
	}
	else if (self.width - padding < _annotationLabel.right) {
		_annotationLabel.right = self.width - padding;
	}
	
	// Vertical alignment.
	
	_annotationLabel.top = _annotationBorderView.bottom + distance;
	
	if (self.height - padding < _annotationLabel.bottom) {
		_annotationLabel.bottom = _annotationBorderView.top - distance;
	}
	if (_annotationLabel.top < 0.0) {
		_annotationLabel.top = 10.0;
	}
}

#pragma mark - [ Private Methods ]

- (CGRect)frameForAnnotatedView
{
	CGRect globalFrame = [self.window convertRect:_annotatedView.bounds fromView:_annotatedView];
	CGRect localFrame = [self convertRect:globalFrame fromView:self.window];
	
	return localFrame;
}

@end
