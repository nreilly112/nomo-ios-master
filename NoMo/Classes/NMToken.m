//
//  NMAccessToken.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMToken.h"


@interface NMToken ()

- (instancetype)initWithTokenString:(NSString *)tokenString
					 expirationDate:(NSDate *)expirationDate;

@end


@implementation NMToken

#pragma mark - [ Initializers ]

- (instancetype)init
{
	return [self initWithTokenString:nil expirationDate:nil];
}

- (instancetype)initWithTokenString:(NSString *)tokenString
					 expirationDate:(NSDate *)expirationDate
{
	self = [super init];
	
	if (self) {
		_tokenString = [tokenString copy];
		_expirationDate = [expirationDate copy];
	}
	
	return self;
}

#pragma mark - [ Constructors ]

+ (instancetype)tokenWithTokenString:(NSString *)tokenString
					  expirationDate:(NSDate *)expirationDate
{
	NMToken *instance = [[[self class] alloc] initWithTokenString:tokenString
												   expirationDate:expirationDate];
	return instance;
}

#pragma mark - [ Methods ]

- (BOOL)isExpired
{
	if (_expirationDate == nil) {
		return YES;
	}

	NSDate *now = [NSDate date];
	
	if ([_expirationDate isEarlierThanDate:now]) {
		return YES;
	}
	
	return NO;
}

#pragma mark - [ NSCopying ]

- (id)copyWithZone:(NSZone *)zone
{
	NMToken *instance = [[[self class] allocWithZone:zone] initWithTokenString:_tokenString
																expirationDate:_expirationDate];
	return instance;
}

@end


BOOL NMTokenIsValid(id<NMToken> token)
{
	if ((token != nil)
	 && (token.tokenString != nil)
	 && ([token isExpired] == NO)) {
		return YES;
	}

	return NO;
}
