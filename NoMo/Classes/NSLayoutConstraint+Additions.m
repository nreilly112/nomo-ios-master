//
//  NSLayoutConstraint+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NSLayoutConstraint+Additions.h"


@implementation NSLayoutConstraint (Additions)

- (BOOL)refersToItem:(id)item
{
	return (self.firstItem == item) || (self.secondItem == item);
}

@end
