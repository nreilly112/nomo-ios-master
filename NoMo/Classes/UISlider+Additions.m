//
//  UISlider+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "UISlider+Additions.h"


@implementation UISlider (Additions)

- (float)fraction
{
	float range = self.maximumValue - self.minimumValue;
	
	if (0.0 < range) {
		return (self.value - self.minimumValue) / range;
	}
	
	return 0.0;
}

- (void)setFraction:(float)value
{
	if (value < self.minimumValue)
		self.value = self.minimumValue;
	else if (self.maximumValue < value)
		self.value = self.maximumValue;
	else
		self.value = self.minimumValue + value * (self.maximumValue - self.minimumValue);
}

@end
