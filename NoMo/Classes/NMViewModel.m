//
//  NMViewModel.m
//  NoMo
//
//  Created by Costas Harizakis on 9/24/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMViewModel.h"


@interface NMViewModel ()

@property (nonatomic, strong) NSMutableDictionary *validationErrors;
@property (nonatomic, assign) BOOL needsValidation;
@property (nonatomic, assign) BOOL delayedDidChange;
@property (nonatomic, assign) NSUInteger updateDepth;
@property (nonatomic, assign) BOOL modified;

@end


@implementation NMViewModel

#pragma mark - [ Initializer ]

- (instancetype)init
{
	self = [super init];
	
	if (self) {
		_validationErrors = [[NSMutableDictionary alloc] init];
		_needsValidation = YES;
		_delayedDidChange = NO;
		_updateDepth = 0;
		_modified = NO;
	}
	
	return self;
}

#pragma mark - [ Properties ]

- (NSDictionary *)errors
{
	return [NSDictionary dictionaryWithDictionary:_validationErrors];
}


#pragma mark - [ Events ]

- (void)didChange
{
	_modified = YES;
	
	if (_updateDepth != 0) {
		_delayedDidChange = YES;
		return;
	}
	
	if ([_delegate respondsToSelector:@selector(viewModelDidChange:)]) {
		[_delegate viewModelDidChange:self];
	}
}

#pragma mark - [ Methods (Modify) ]

- (void)beginUpdates
{
	if (_updateDepth == 0) {
		_delayedDidChange = NO;
	}
	
	_updateDepth += 1;
}

- (void)endUpdates
{
	_updateDepth -= 1;
	
	if (_updateDepth == 0) {
		if (_delayedDidChange) {
			_delayedDidChange = NO;
			if (_modified) {
				[self didChange];
			}
		}
	}
}

- (BOOL)isModified
{
	return _modified;
}

- (void)clearModified
{
	_modified = NO;
}

#pragma mark - [ Methods (Validation) ]

- (void)setNeedsValidation
{
	_needsValidation = YES;
}

- (void)validateIfNeeded
{
	if (_needsValidation) {
		[self validate];
	}
}

- (void)validate
{
	_needsValidation = NO;
	
	[self removeAllErrors];
	[self performValidation];
}

- (void)setErrorMessage:(NSString *)message forKey:(NSString *)key
{
	[self setError:[self errorWithMessage:message] forKey:key];
}

- (void)setError:(NSError *)error forKey:(NSString *)key
{
	if (key != nil) {
		[_validationErrors setObjectOrNil:error forKey:key];
	}
}

- (void)removeAllErrors
{
	[_validationErrors removeAllObjects];
}

- (BOOL)isValid
{
	[self validateIfNeeded];
	
	return (_validationErrors.count == 0);
}

#pragma mark - [ Methods (Protected) ]

- (void)performValidation
{
	// Should be overridden.
}

#pragma mark - [ Methods (Helpers) ]

- (NSError *)errorWithMessage:(NSString *)message
{
	NSString *domain = @"ViewModel";
	NSDictionary *userInfo = @{ @"message": message ?: [NSNull null] };
	
	return [NSError errorWithDomain:domain code:-1 userInfo:userInfo];
}

@end
