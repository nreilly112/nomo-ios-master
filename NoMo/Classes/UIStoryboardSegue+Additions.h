//
//  UIStoryboardSegue+Additions.h
//  NoMo
//
//  Created by Costas Harizakis on 16/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface UIStoryboardSegue (Additions)

- (void)notifyWhenTransitionCompletesUsingBlock:(void (^)(void))block;

@end
