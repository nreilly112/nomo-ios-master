//
//  UIImageView+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "UIImageView+Additions.h"


@implementation UIImageView (Additions)

+ (UIImage *)imageNamed:(NSString *)imageName
{
	static dispatch_once_t onceToken;
	static NSMutableDictionary *images;
	
	dispatch_once(&onceToken, ^{
		images = [[NSMutableDictionary alloc] init];
	});
	
	UIImage *image = nil;
	
	if (imageName != nil) {
		image = [images objectOrNilForKey:imageName];
		
		if (image == nil) {
			image = [UIImage imageNamed:imageName];
			
			if (image != nil) {
				[images setObject:image forKey:imageName];
			}
		}
	}

	return image;
}

- (instancetype)initWithImageNamed:(NSString *)imageName
{
	return [self initWithImage:[UIImageView imageNamed:imageName]];
}

- (instancetype)initWithAnimatedImageNamed:(NSString *)imageName duration:(NSTimeInterval)duration
{
	return [self initWithImage:[UIImage animatedImageNamed:imageName duration:duration]];
}

- (void)setImageNamed:(NSString *)imageName
{
	self.image = [UIImageView imageNamed:imageName];
}

@end
