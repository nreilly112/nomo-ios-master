//
//  UIStoryboardSegue+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 16/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "UIStoryboardSegue+Additions.h"


@implementation UIStoryboardSegue (Additions)

- (void)notifyWhenTransitionCompletesUsingBlock:(void (^)(void))block
{
	if (block) {
		[self performBlockOnMainThread:^(void) {
			id<UIViewControllerTransitionCoordinator> coordinator = self.sourceViewController.transitionCoordinator ?: self.destinationViewController.transitionCoordinator;
			[coordinator animateAlongsideTransition:nil completion:^(id context) {
				block();
			}];
		}];
	}
}

@end
