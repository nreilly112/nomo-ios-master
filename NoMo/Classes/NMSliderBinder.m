//
//  NMSliderBinder.m
//  NoMo
//
//  Created by Costas Harizakis on 9/26/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMSliderBinder.h"


@implementation NMSliderBinder

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[self updateObserverWithSliderController:nil];
}

#pragma mark - [ Properties ]

- (void)setSliderControl:(UISlider *)sliderControl
{
	if (_sliderControl != sliderControl) {
		[self updateObserverWithSliderController:sliderControl];
	}
}

#pragma mark - [ NMBinder ]

- (void)didChangeValue
{
	_sliderControl.value = [self.value floatValue];
}

#pragma mark - [ Actions ]

- (void)didChangeSliderValue:(id)sender
{
	[self setValue:[NSNumber numberWithFloat:_sliderControl.value]];
}

#pragma mark - [ Methods (Private) ]

- (void)updateObserverWithSliderController:(UISlider *)sliderControl
{
	if (_sliderControl != nil) {
		[_sliderControl removeTarget:self action:@selector(didChangeSliderValue:) forControlEvents:UIControlEventValueChanged];
	}
	
	_sliderControl = sliderControl;
	
	if (_sliderControl != nil) {
		[_sliderControl addTarget:self action:@selector(didChangeSliderValue:) forControlEvents:UIControlEventValueChanged];
		_sliderControl.value = [self.value floatValue];
	}
}

@end
