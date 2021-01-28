//
//  UISearchBar+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "UISearchBar+Additions.h"


@implementation UISearchBar (Additions)

- (UITextField *)textField
{
	UIView *view = [self descendantOrSelfWithClass:[UITextField class]];
	
	return (UITextField *)view;
}

@end
