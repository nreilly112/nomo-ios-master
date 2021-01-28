//
//  NMItem.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMItem.h"


@implementation NMItem

#pragma mark - [ SSESerializing (Initializers and Constructors) ]

- (instancetype)initWithProperties:(NSDictionary *)properties
{
	self = [super init];
	
	if (self) {
		// Nothing to be done.
	}
	
	return self;
}

+ (instancetype)itemWithProperties:(NSDictionary *)properties
{
	return [[self alloc] initWithProperties:properties];
}

#pragma mark - [ SSESerializing (Properties) ]

- (NSMutableDictionary *)properties
{
	NSMutableDictionary *properties = [NSMutableDictionary dictionary];
	
	return properties;
}

#pragma mark - [ NSCopying ]

- (instancetype)copyWithZone:(NSZone *)zone
{
	return [[[self class] allocWithZone:zone] initWithProperties:self.properties];
}

@end
