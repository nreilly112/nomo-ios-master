//
//  NoMoContext.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoContext.h"
#import "NMUserSettingsModel.h"


NSString * const kActionAcceptTermsAndConditions = @"AcceptTermsAndConditions";
NSString * const kActionDemonstrateSummary = @"DemonstrateSummary";
NSString * const kActionDemonstrateDetails = @"DemonstrateDetails";
NSString * const kActionDemonstrateSettings = @"DemonstrateSettings";


@interface NoMoContext ()

+ (NSString *)defaultCurrencyCode;

@end


@implementation NoMoContext

@synthesize currencyCode = _currencyCode;

#pragma mark - [ Properties ]

- (NSString *)currencyCode
{
	return _currencyCode ?: [NoMoContext defaultCurrencyCode];
}

- (void)setCurrencyCode:(NSString *)currencyCode
{
	if (![_currencyCode isEqualToString:currencyCode]) {
		[self willChangeValueForKey:@"currencyCode"];
		_currencyCode = currencyCode;
		[self didChangeValueForKey:@"currencyCode"];
	}
}

- (void)setApplicationPersona:(NMApplicationPersona)applicationPersona
{
	if (_applicationPersona != applicationPersona) {
		[self willChangeValueForKey:@"applicationPersona"];
		_applicationPersona = applicationPersona;
		[self didChangeValueForKey:@"applicationPersona"];
	}
}

- (BOOL)isNetworkAvailable
{
	AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
	
	if (reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
		return NO;
	}
	
	return YES;
}

#pragma mark - [ Methods ]

- (BOOL)hasPerformedActionNamed:(NSString *)actionName
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *actionKey = [self keyForActionNamed:actionName];

	return [userDefaults boolForKey:actionKey];
}

- (void)didPerformActionNamed:(NSString *)actionName
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *actionKey = [self keyForActionNamed:actionName];
	
	[userDefaults setBool:YES forKey:actionKey];
	[userDefaults synchronize];
}

#pragma mark - [ NSKeyValueObserving ]

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
	return NO;
}

#pragma mark - [ Private Methods ]

- (NSString *)keyForActionNamed:(NSString *)actionName
{
	return [NSString stringWithFormat:@"action:%@", actionName ?: @""];
}

+ (NSString *)getRecognizedCurrency {
    NSUserDefaults *currencySettings = [NSUserDefaults standardUserDefaults];
    NSString *recognizedCurrency  = [currencySettings objectForKey:@"recognizedCurrency"];
    return recognizedCurrency;
}


#pragma mark - [ Constructors (Static) ]

+ (instancetype)sharedContext
{
	static NoMoContext *instance;
	static dispatch_once_t once;
	
	dispatch_once(&once, ^(void) {
		instance = [[NoMoContext alloc] init];
	});
	
	return instance;
}

#pragma mark - [ Defaults (Static) ]

+ (NSString *)defaultCurrencyCode
{
    NSString *recognizedCurrency = [self getRecognizedCurrency];
    if (recognizedCurrency != nil) {
        return recognizedCurrency;
    }
	return @"GBP";
}

@end
