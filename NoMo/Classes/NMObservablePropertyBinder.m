//
//  NMObservablePropertyBinder.m
//  NoMo
//
//  Created by Costas Harizakis on 9/24/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMObservablePropertyBinder.h"


@implementation NMObservablePropertyBinder

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[self updateObserverWithView:nil propertyName:nil];
}

#pragma mark - [ Properties ]

- (void)setView:(UIView *)view
{
	if (_view != view) {
		[self updateObserverWithView:view propertyName:_observablePropertyName];
	}
}

- (void)setObservablePropertyName:(NSString *)observablePropertyName
{
	if (![_observablePropertyName isEqualToString:observablePropertyName]) {
		[self updateObserverWithView:_view propertyName:observablePropertyName];
	}
}

#pragma mark - [ NMBinder ]

- (void)didChangeValue
{
	[_view setValue:self.value forKey:_observablePropertyName];
}

#pragma mark - [ Methods (Observer) ]

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ((object == _view) && ([_observablePropertyName isEqualToString:keyPath])) {
		[self setValue:[_view valueForKey:_observablePropertyName]];
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark - [ Methods (Private) ]

- (void)updateObserverWithView:(UIView *)view propertyName:(NSString *)propertyName
{
	if (_observablePropertyName != nil) {
		[_view removeObserver:self forKeyPath:_observablePropertyName context:NULL];
	}
	
	_view = view;
	_observablePropertyName = [propertyName copy];
	
	if (_observablePropertyName != nil) {
		[_view addObserver:self forKeyPath:_observablePropertyName options:NSKeyValueObservingOptionNew context:NULL];
		[_view setValue:self.value forKey:_observablePropertyName];
		[self didChangeValue];
	}
}

@end
