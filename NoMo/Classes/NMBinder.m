//
//  NMBinder.m
//  NoMo
//
//  Created by Costas Harizakis on 9/24/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMBinder.h"


@interface NMBinder ()

@property (nonatomic, assign) BOOL updatingValue;

@end


@implementation NMBinder

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[self updateObserverWithObject:nil key:nil];
}

#pragma mark - [ Initializer ]

- (instancetype)init
{
	return [self initWithObject:nil key:nil];
}

- (instancetype)initWithObject:(id)object key:(NSString *)key
{
	self = [super init];
	
	if (self) {
		[self updateObserverWithObject:object key:key];
	}
	
	return self;
}

#pragma mark - [ Properties ]

- (void)setObject:(id)object
{
	if (_object != object) {
		[self updateObserverWithObject:object key:_key];
	}
}

- (void)setKey:(NSString *)key
{
	if (![_key isEqualToString:key]) {
		[self updateObserverWithObject:_object key:key];
	}
}

- (id)value
{
	return [_object valueForKey:_key];
}

- (void)setValue:(id)value
{
	_updatingValue = YES;
	[_object setValue:value forKey:_key];
	_updatingValue = NO;
}

#pragma mark - [ Methods ]

- (void)didChangeValue
{
	// Should be overriden by derived classes.
}

#pragma mark - [ Methods (Observer) ]

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ((object == _object) && ([_key isEqualToString:keyPath])) {
		if (!_updatingValue) {
			[self didChangeValue];
		}
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark - [ Methods (Private) ]

- (void)updateObserverWithObject:(id)object key:(NSString *)key
{
	if (_key != nil) {
		[_object removeObserver:self forKeyPath:_key context:NULL];
	}
	
	_object = object;
	_key = [key copy];
	
	if (_key != nil) {
		[_object addObserver:self forKeyPath:_key options:NSKeyValueObservingOptionNew context:NULL];
		[self didChangeValue];
	}
}

@end
