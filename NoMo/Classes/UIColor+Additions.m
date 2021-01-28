//
//  UIColor+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "UIColor+Additions.h"


@implementation UIColor (Additions)

+ (UIColor *)colorWithRGB:(NSUInteger)rgb
{
	return [UIColor colorWithRGB:rgb alpha:1.0];
}

+ (UIColor *)colorWithRGB:(NSUInteger)rgb alpha:(CGFloat)a
{
	return [UIColor colorWithRed:(((rgb & 0xFF0000) >> 16) / 255.0)
						   green:(((rgb & 0x00FF00) >>  8) / 255.0)
							blue:(((rgb & 0x0000FF) >>  0) / 255.0) alpha:a];
}

- (UIColor *)colorWithHalfBrightnessComponent
{
	CGFloat c[4] = { 0.0, 0.0, 0.0, 0.0 };
	
	[self getHue:&c[0] saturation:&c[1] brightness:&c[2] alpha:&c[3]];
	
	c[2] *= 0.5;
	
	return [UIColor colorWithHue:c[0]
					  saturation:c[1]
					  brightness:c[2]
						   alpha:c[3]];
}

@end
