//
//  NMOAuth2Credentials.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMOAuth2Credentials.h"


@interface NMOAuth2Credentials ()

- (instancetype)initWithClientId:(NSString *)clientId
					clientSecret:(NSString *)clientSecret;

@end


@implementation NMOAuth2Credentials

#pragma mark - [ Initializers ]

- (instancetype)init
{
	return [self initWithClientId:nil clientSecret:nil];
}

- (instancetype)initWithClientId:(NSString *)clientId
					clientSecret:(NSString *)clientSecret
{
	self = [super init];
	
	if (self) {
		_clientId = [clientId copy];
		_clientSecret = [clientSecret copy];
	}
	
	return self;
}

#pragma mark - [ Constructors ]

+ (instancetype)credentialsWithClientId:(NSString *)clientId
						   clientSecret:(NSString *)clientSecret
{
	NMOAuth2Credentials *instance = [[[self class] alloc] initWithClientId:clientId
															  clientSecret:clientSecret];
	return instance;
}

#pragma mark - [ NSCopying ]

- (id)copyWithZone:(NSZone *)zone
{
	NMOAuth2Credentials *instance = [[[self class] allocWithZone:zone] initWithClientId:_clientId
																		   clientSecret:_clientSecret];
	return instance;
}

@end
