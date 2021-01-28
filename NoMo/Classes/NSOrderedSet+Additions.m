//
//  NSOrderedSet+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 10/6/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NSOrderedSet+Additions.h"
#import "NMSerializing.h"


@implementation NSOrderedSet (NMSerializing)

- (NSMutableArray *)arrayByConvertingItemsToProperties
{
	NSMutableArray *arrayOfProperties = [NSMutableArray arrayWithCapacity:self.count];
	
	for (id value in self) {
		if ([value conformsToProtocol:@protocol(NMSerializing)]) {
			id<NMSerializing> item = value;
			[arrayOfProperties addObject:item.properties];
		}
	}
	
	return arrayOfProperties;
}

- (NSMutableArray *)arrayByConvertingPropertiesToItemsOfKind:(Class)class
{
	if (![class conformsToProtocol:@protocol(NMSerializing)]) {
		return nil;
	}
	
	NSMutableArray *arrayOfItems = [NSMutableArray arrayWithCapacity:self.count];
	
	for (id value in self) {
		if ([value isKindOfClass:[NSDictionary class]]) {
			id<NMSerializing> item = [class alloc];
			item = [item initWithProperties:value];
			[arrayOfItems addObject:item];
		}
	}
	
	return arrayOfItems;
}

@end