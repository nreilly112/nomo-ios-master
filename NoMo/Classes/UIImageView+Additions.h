//
//  UIImageView+Additions.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface UIImageView (Additions)

- (instancetype)initWithImageNamed:(NSString *)imageName;
- (instancetype)initWithAnimatedImageNamed:(NSString *)imageName duration:(NSTimeInterval)duration;

- (void)setImageNamed:(NSString *)imageName;

@end
