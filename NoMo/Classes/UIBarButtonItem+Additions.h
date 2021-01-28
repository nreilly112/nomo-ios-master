//
//  UIBarButtonItem+Additions.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface UIBarButtonItem (Additions)

+ (UIBarButtonItem *)plainBarButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)plainBarButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)plainBarButtonItemWithImageNamed:(NSString *)imageName target:(id)target action:(SEL)action;

@end
