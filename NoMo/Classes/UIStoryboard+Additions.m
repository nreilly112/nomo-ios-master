//
//  UIStoryboard+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "UIStoryboard+Additions.h"


@implementation UIStoryboard (Additions)

+ (UIStoryboard *)mainStoryboard
{
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *name = [bundle.infoDictionary objectForKey:@"UIMainStoryboardFile"];

	return [UIStoryboard storyboardWithName:name bundle:bundle];
}

@end
