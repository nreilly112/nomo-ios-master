//
//  NMButton.m
//  NoMo
//
//  Created by Costas Harizakis on 10/19/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMButton.h"


@interface NMButton ()

@property (nonatomic, strong) UIColor *preferredBackgroundColor;

- (void)updateBackgroundColorAnimated:(BOOL)animated;
- (UIColor *)backgroundColorForCurrentState;

@end


@implementation NMButton

#pragma mark - [ UIView Members ]

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
	if (_preferredBackgroundColor != backgroundColor) {
		_preferredBackgroundColor = backgroundColor;
	}
	
	[self updateBackgroundColorAnimated:NO];
}

#pragma mark - [ UIControl Members ]

- (void)setEnabled:(BOOL)enabled
{
	[super setEnabled:enabled];
	[self updateBackgroundColorAnimated:YES];
}

#pragma mark - [ Private Methods ]

- (void)updateBackgroundColorAnimated:(BOOL)animated
{
	UIColor *backgroundColor = [self backgroundColorForCurrentState];
	
	if (animated) {
		[UIView animateWithDuration:0.25 animations:^(void) {
			[super setBackgroundColor:backgroundColor];
		}];
	}
	else {
		[super setBackgroundColor:backgroundColor];
	}
}

- (UIColor *)backgroundColorForCurrentState
{
	if (self.enabled) {
		return _preferredBackgroundColor;
	}
	else {
		return [_preferredBackgroundColor colorWithAlphaComponent:0.5];
	}
}

@end
