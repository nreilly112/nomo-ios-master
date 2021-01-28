//
//  NMUserSettingsViewModel.m
//  NoMo
//
//  Created by Costas Harizakis on 9/24/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMUserSettingsViewModel.h"


@implementation NMUserSettingsViewModel

- (void)setPreferredCurrencyCode:(NSString *)preferredCurrencyCode
{
	if (![_preferredCurrencyCode isEqualToString:preferredCurrencyCode]) {
		[self willChangeValueForKey:@"preferredCurrencyCode"];
		_preferredCurrencyCode = preferredCurrencyCode;
		[self didChangeValueForKey:@"preferredCurrencyCode"];
		[self setNeedsValidation];
		[self didChange];
	}
}

- (void)setIncrementNotificationThreshold:(CGFloat)incrementNotificationThreshold
{
	if (_incrementNotificationThreshold != incrementNotificationThreshold) {
		[self willChangeValueForKey:@"incrementNotificationThreshold"];
		_incrementNotificationThreshold = incrementNotificationThreshold;
		[self didChangeValueForKey:@"incrementNotificationThreshold"];
		[self setNeedsValidation];
		[self didChange];
	}
}

- (void)setDecrementNotificationThreshold:(CGFloat)decrementNotificationThreshold
{
	if (_decrementNotificationThreshold != decrementNotificationThreshold) {
		[self willChangeValueForKey:@"decrementNotificationThreshold"];
		_decrementNotificationThreshold = decrementNotificationThreshold;
		[self didChangeValueForKey:@"decrementNotificationThreshold"];
		[self setNeedsValidation];
		[self didChange];
	}
}

- (void)setApplicationPersona:(NSUInteger)applicationPersona
{
	if (_applicationPersona != applicationPersona) {
		[self willChangeValueForKey:@"applicationPersona"];
		_applicationPersona = applicationPersona;
		[self didChangeValueForKey:@"applicationPersona"];
		[self setNeedsValidation];
		[self didChange];
	}
}

- (void)setNotificationsEnabled:(BOOL)notificationsEnabled
{
	if (_notificationsEnabled != notificationsEnabled) {
		[self willChangeValueForKey:@"notificationsEnabled"];
		_notificationsEnabled = notificationsEnabled;
		[self didChangeValueForKey:@"notificationsEnabled"];
		[self setNeedsValidation];
		[self didChange];
	}
}

- (void)setIncludeOverdraft:(BOOL)includeOverdraft
{
    if (_includeOverdraft != includeOverdraft) {
        [self willChangeValueForKey:@"includeOverdraft"];
        _includeOverdraft = includeOverdraft;
        [self didChangeValueForKey:@"includeOverdraft"];
        [self setNeedsValidation];
        [self didChange];
    }
}
@end
