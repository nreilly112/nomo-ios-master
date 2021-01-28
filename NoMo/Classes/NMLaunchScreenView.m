//
//  NMLaunchScreenView.m
//  NoMo
//
//  Created by Costas Harizakis on 10/7/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMLaunchScreenView.h"
#import "NMSwipeIndicatorView.h"


@implementation NMLaunchScreenView

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self addContentSubview:[self contentViewFromNib]];
/*
	NMSwipeIndicatorView *view = [[NMSwipeIndicatorView alloc] initWithFrame:self.bounds];
	view.autoresizingMask = UIViewAutoresizingFlexibleSize;
	view.repeats = 5;
	[self addSubview:view];
	
	[self performBlockOnMainThread:^(void) {
		[view setHidden:NO];
	} afterDelay:1.0];
 */
}

@end
