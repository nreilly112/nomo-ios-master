//
//  UIImage+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "UIImage+Additions.h"


@implementation UIImage (Additions)

- (UIImage *)normalizedImage
{
	if (self.imageOrientation == UIImageOrientationUp) {
		return self;
	}
	
	UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
	
	[self drawInRect:CGRectMakeWithOriginSize(CGPointZero, self.size)];
	UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return normalizedImage;
}

- (UIImage *)imageWithAlphaComponent:(CGFloat)alpha
{
	UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect area = CGRectMakeWithOriginSize(CGPointZero, self.size);
	
	CGContextScaleCTM(context, 1, -1);
	CGContextTranslateCTM(context, 0, -CGRectGetHeight(area));
	CGContextSetBlendMode(context, kCGBlendModeMultiply);
	CGContextSetAlpha(context, alpha);
	
	CGContextDrawImage(context, area, self.CGImage);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return image;
}

@end
