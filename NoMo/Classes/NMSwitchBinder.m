//
//  NMSwitchBinder.m
//  NoMo
//
//  Created by Costas Harizakis on 9/24/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMSwitchBinder.h"


@implementation NMSwitchBinder

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[self updateObserverWithSwitchController:nil];
}

#pragma mark - [ Properties ]

- (void)setSwitchControl:(UISwitch *)switchControl
{
	if (_switchControl != switchControl) {
		[self updateObserverWithSwitchController:switchControl];
	}
}

#pragma mark - [ NMBinder ]

- (void)didChangeValue
{
	_switchControl.on = [self.value boolValue];
}

#pragma mark - [ Actions ]

- (void)didChangeSwitchValue:(id)sender
{
	[self setValue:[NSNumber numberWithBool:_switchControl.on]];
}

#pragma mark - [ Methods (Private) ]

- (void)updateObserverWithSwitchController:(UISwitch *)switchControl
{
	if (_switchControl != nil) {
		[_switchControl removeTarget:self action:@selector(didChangeSwitchValue:) forControlEvents:UIControlEventValueChanged];
	}
	
	_switchControl = switchControl;
	
	if (_switchControl != nil) {
		[_switchControl addTarget:self action:@selector(didChangeSwitchValue:) forControlEvents:UIControlEventValueChanged];
		_switchControl.on = [self.value boolValue];
	}
}

@end
