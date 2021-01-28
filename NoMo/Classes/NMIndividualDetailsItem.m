//
//  NMIndividualDetailsItem.m
//  NoMo
//
//  Created by Costas Harizakis on 9/29/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMIndividualDetailsItem.h"


#define kReferenceKey @"Reference"


@implementation NMIndividualDetailsItem

- (instancetype)initWithProperties:(NSDictionary *)properties
{
	self = [super initWithProperties:properties];
	
	if (self) {
		_reference = [[properties objectOrNilForKey:kReferenceKey] copy];
	}
	
	return self;
}

- (NSMutableDictionary *)properties
{
	NSMutableDictionary *properties = [super properties];
	[properties setObjectOrNil:_reference forKey:kReferenceKey];
	
	return properties;
}

@end
