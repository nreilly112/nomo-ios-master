//
//  NMIdentity.m
//  NoMo
//
//  Created by Costas Harizakis on 9/30/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMIdentity.h"


@interface NMIdentity ()

+ (instancetype)identityWithGrantType:(NSString *)grantType
                             clientId:(NSString *)clientId
                         clientSecret:(NSString *)clientSecret
                                scope:(NSString *)scope;

@end


@implementation NMIdentity

#pragma mark - [ Initializers ]

- (instancetype)init
{
    return [self initWithGrantType:nil clientId:nil clientSecret:nil scope:nil];
}

- (instancetype)initWithGrantType:(NSString *)grantType
                         clientId:(NSString *)clientId
                     clientSecret:(NSString *)clientSecret
                            scope:(NSString *)scope;
{
	self = [super init];
	
	if (self) {
		_grantType = [grantType copy];
		_clientId = [clientId copy];
        _clientSecret = [clientSecret copy];
        _scope = [scope copy];
	}
	
	return self;
}

#pragma mark - [ Constructors ]

+ (instancetype)identityWithGrantType:(NSString *)grantType
                             clientId:(NSString *)clientId
                         clientSecret:(NSString *)clientSecret
                                scope:(NSString *)scope;
{
    NMIdentity *instance = [[[self class] alloc] initWithGrantType:grantType
                                                          clientId:clientId
                                                      clientSecret:clientSecret
                                                             scope:scope];
	return instance;
}

#pragma mark - [ NSObject ]
/*
- (BOOL)isEqual:(id)object
{
	if ([object isKindOfClass:[NMIdentity class]]) {
		NMIdentity *other = object;
		
		if (([_name isEqualToString:other.name])
		 && ([_domain isEqualToString:other.domain])) {
			return YES;
		}
	}
	
	return NO;
}

- (NSUInteger)hash
{
	return _name.hash ^ _domain.hash;
}

#pragma mark - [ NSCopying ]

- (id)copyWithZone:(NSZone *)zone
{
	 NMIdentity *instance = [[[self class] allocWithZone:zone] initWithName:_name
																	 domain:_domain];
	return instance;
}
*/
@end
