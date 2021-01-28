//
//  NMSwipeIndicatorView.m
//  NoMo
//
//  Created by Costas Harizakis on 17/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMSwipeIndicatorView.h"

@interface NMSwipeIndicatorView ()

@property (nonatomic, weak) UIView *container;

@end


@implementation NMSwipeIndicatorView

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
	UIView *container = [[UIView alloc] initWithFrame:CGRectZero];
	container.center = CGPointMake(0.5 * self.width, 0.5 * self.height + 500.0);
	[self addSubview:container];
	_container = container;

	UIImageView *imageView = [[UIImageView alloc] initWithImageNamed:@"hand-pointer"];
	imageView.center = CGPointMake(0.0, -500.0);
	imageView.contentMode = UIViewContentModeCenter;
	[container addSubview:imageView];
}

- (void)setHidden:(BOOL)hidden
{
	[super setHidden:hidden];
	
	if (hidden) {
		[self.layer removeAllAnimations];
	}
	else {
		[self animate];
	}
}

- (void)animate
{
	[self animateWithReverse:_reverse repeats:MAX(_repeats, 1)];
}

- (void)animateWithReverse:(BOOL)reverse repeats:(NSInteger)repeats
{
	CGAffineTransform startTransform = CGAffineTransformRotate(CGAffineTransformIdentity, -(2.0 * M_PI) * 0.025);
	CGAffineTransform endTransform = CGAffineTransformRotate(CGAffineTransformIdentity, (2.0 * M_PI) * 0.025);
	
	if (reverse) {
		CGAffineTransform transform = startTransform;
		startTransform = endTransform;
		endTransform = transform;
	}

	_container.alpha = 0.0;
	_container.transform = startTransform;
	
	[UIView animateWithDuration:0.25 delay:0.0 options:0 animations:^(void) {
		self.container.alpha = 1.0;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void) {
			self.container.transform = endTransform;
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^(void) {
				self.container.alpha = 0.0;
			} completion:^(BOOL finished) {
				self.container.transform = startTransform;
	
				if (1 < repeats) {
					[self animateWithReverse:reverse repeats:(repeats - 1)];
				}

			}];
		}];
	}];
	
	
}

@end
