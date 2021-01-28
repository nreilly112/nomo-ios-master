//
//  NMSecurityContext.m
//  NoMo
//
//  Created by Costas Harizakis on 9/30/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMSecurityContext.h"


NSString * const kNMSecurityContextDidChangeNotification = @"com.miicard.securityContext.didChange";


@interface NMSecurityContext ()

- (void)didChange;

@end


@implementation NMSecurityContext

#pragma mark - [ Properties ]

- (void)setAccessToken:(id<NMToken>)accessToken
{
	if (_accessToken != accessToken) {
		[self willChangeValueForKey:@"accessToken"];
		_accessToken = accessToken;
		[self didChangeValueForKey:@"accessToken"];
		[self didChange];
	}
}

#pragma mark - [ Events ]

- (void)didChange
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kNMSecurityContextDidChangeNotification
														object:self
													  userInfo:nil];
}

#pragma mark - [ NSKeyValueObserving ]

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
	return NO;
}

@end
