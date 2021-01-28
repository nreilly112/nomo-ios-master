//
//  NMStepSliderBinder.m
//  NoMo
//
//  Created by Costas Harizakis on 10/19/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMStepSliderBinder.h"

@implementation NMStepSliderBinder

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[self updateObserverWithStepSliderController:nil];
}

#pragma mark - [ Properties ]

- (void)setStepSliderControl:(StepSlider *)stepSliderControl
{
	if (_stepSliderControl != stepSliderControl) {
		[self updateObserverWithStepSliderController:stepSliderControl];
	}
}

#pragma mark - [ NMBinder ]

- (void)didChangeValue
{
	_stepSliderControl.index = [self.value unsignedIntegerValue];
}

#pragma mark - [ Actions ]

- (void)didChangeStepSliderValue:(id)sender
{
	[self setValue:[NSNumber numberWithFloat:_stepSliderControl.index]];
}

#pragma mark - [ Methods (Private) ]

- (void)updateObserverWithStepSliderController:(StepSlider *)stepSliderControl
{
	if (_stepSliderControl != nil) {
		[_stepSliderControl removeTarget:self action:@selector(didChangeStepSliderValue:) forControlEvents:UIControlEventValueChanged];
	}
	
	_stepSliderControl = stepSliderControl;
	
	if (_stepSliderControl != nil) {
		[_stepSliderControl addTarget:self action:@selector(didChangeStepSliderValue:) forControlEvents:UIControlEventValueChanged];
		_stepSliderControl.index = [self.value unsignedIntegerValue];
	}
}

@end
