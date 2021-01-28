//
//  NMTextFieldBinder.m
//  NoMo
//
//  Created by Costas Harizakis on 9/24/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMTextFieldBinder.h"


@implementation NMTextFieldBinder

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[self updateObserverWithTextField:nil];
}

#pragma mark - [ Properties ]

- (void)setTextField:(UITextField *)textField
{
	if (_textField != textField) {
		[self updateObserverWithTextField:textField];
	}
}

#pragma mark - [ SSEBinder ]

- (void)didChangeValue
{
	_textField.text = self.value;
}

#pragma mark - [ Actions ]

- (void)didChangeTextFieldValue:(id)sender
{
	[self setValue:_textField.text];
}

#pragma mark - [ Methods (Private) ]

- (void)updateObserverWithTextField:(UITextField *)textField
{
	if (_textField != nil) {
		[_textField removeTarget:self action:@selector(didChangeTextFieldValue:) forControlEvents:UIControlEventEditingChanged];
	}
	
	_textField = textField;
	
	if (_textField != nil) {
		[_textField addTarget:self action:@selector(didChangeTextFieldValue:) forControlEvents:UIControlEventEditingChanged];
		_textField.text = self.value;
	}
}

@end
