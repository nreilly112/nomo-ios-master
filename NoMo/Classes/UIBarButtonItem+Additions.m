//
//  UIBarButtonItem+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "UIBarButtonItem+Additions.h"


@implementation UIBarButtonItem (Additions)

+ (UIBarButtonItem *)plainBarButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
	return [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
}

+ (UIBarButtonItem *)plainBarButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action
{
	return [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:action];
}

+ (UIBarButtonItem *)plainBarButtonItemWithImageNamed:(NSString *)imageName target:(id)target action:(SEL)action
{
	return [UIBarButtonItem plainBarButtonItemWithImage:[UIImage imageNamed:imageName] target:target action:action];
}

@end
