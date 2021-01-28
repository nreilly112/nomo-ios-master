//
//  NMAccessTokenItem.m
//  NoMo
//
//  Created by Costas Harizakis on 10/18/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMAccessTokenItem.h"


#define kTokenTypeKey @"token_type"
#define kAccessTokenStringKey @"access_token"
#define kRefreshTokenStringKey @"refresh_token"
#define kLastRefreshDateKey @"date"
#define kExpirationTimeIntervalKey @"expires_in"
#define kScopeKey @"scope"


@interface NMAccessTokenItem ()

@property (nonatomic, assign, readonly) NSTimeInterval expirationTimeInterval;

@end


@implementation NMAccessTokenItem

#pragma mark - [ Initializers ]

- (instancetype)initWithProperties:(NSDictionary *)properties
{
	self = [super init];
	
	if (self) {
		_tokenType = [[properties objectOrNilForKey:kTokenTypeKey] copy];
		_accessTokenString = [[properties objectOrNilForKey:kAccessTokenStringKey] copy];
		_refreshTokenString = [[properties objectOrNilForKey:kRefreshTokenStringKey] copy];
		_lastRefreshDate = [properties dateOrNilForKey:kLastRefreshDateKey notFound:[NSDate date]];
		_expirationTimeInterval = [properties doubleValueOrZeroForKey:kExpirationTimeIntervalKey];
		_scope = [[properties objectOrNilForKey:kRefreshTokenStringKey] copy];
	}
	
	return self;
}

#pragma mark - [ Properties ]

- (NSDate *)expirationDate
{
	NSDate *expirationDate = [NSDate distantFuture];
	
	if (_lastRefreshDate && _expirationTimeInterval) {
		expirationDate = [_lastRefreshDate dateByAddingTimeInterval:_expirationTimeInterval];
	}
	
	return expirationDate;
}

#pragma mark - [ NMSerializing Properties ]

- (NSMutableDictionary *)properties
{
	NSMutableDictionary *properties = [super properties];
	[properties setObjectOrNil:_tokenType forKey:kTokenTypeKey];
	[properties setObjectOrNil:_accessTokenString forKey:kAccessTokenStringKey];
	[properties setObjectOrNil:_refreshTokenString forKey:kRefreshTokenStringKey];
	[properties setObjectOrNil:[_lastRefreshDate stringRFC3339] forKey:kLastRefreshDateKey];
	[properties setDoubleValue:_expirationTimeInterval forKey:kExpirationTimeIntervalKey];
	[properties setObjectOrNil:_scope forKey:kScopeKey];
	
	return properties;
}

#pragma mark - [ Methods ]

- (BOOL)isExpired
{
	return [self.expirationDate isEarlierThanDate:[NSDate date]];
}

@end
