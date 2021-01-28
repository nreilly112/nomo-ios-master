//
//  UIColor+Additions.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface UIColor (Additions)

+ (UIColor *)colorWithRGB:(NSUInteger)rgb;
+ (UIColor *)colorWithRGB:(NSUInteger)rgb alpha:(CGFloat)a;

- (UIColor *)colorWithHalfBrightnessComponent;

@end
