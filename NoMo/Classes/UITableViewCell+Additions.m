//
//  UITableViewCell+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "UITableViewCell+Additions.h"


@implementation UITableViewCell (Additions)

- (UITableView *)tableView
{
	UIView *view = [self ancestorOrSelfWithClass:[UITableView class]];
	
	return (UITableView *)view;
}

@end
