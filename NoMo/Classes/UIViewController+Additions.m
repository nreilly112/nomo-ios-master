//
//  UIViewController+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "UIViewController+Additions.h"


#define kUIViewControllerTransitionDuration 0.5


@implementation UIViewController (Additions)

- (void)show:(BOOL)show view:(UIView *)view animated:(BOOL)animated
{
	if (view) {
		if (show) {
			[self presentView:view animated:animated];
		}
		else {
			[self dismissView:view animated:animated];
		}
	}
}

#pragma mark - [ Methods (Private) ]

- (void)presentView:(UIView *)view animated:(BOOL)animated
{
	[self.view addContentSubview:view];

	if (animated) {
		view.alpha = 0.0;
		view.hidden = NO;
		
		[UIView animateWithDuration:kUIViewControllerTransitionDuration animations:^(void) {
			view.alpha = 1.0;
		}];
	}
	else {
		view.alpha = 1.0;
		view.hidden = NO;
	}
}

- (void)dismissView:(UIView *)view animated:(BOOL)animated
{
	if (animated) {
		[UIView animateWithDuration:kUIViewControllerTransitionDuration animations:^(void) {
			view.alpha = 0.0;
		} completion:^(BOOL finished) {
			[view removeFromSuperview];
			view.alpha = 1.0;
		}];
	}
	else {
		[view removeFromSuperview];
		view.alpha = 1.0;
	}
}

@end
