//
//  NMIndividualItem.m
//  NoMo
//
//  Created by Costas Harizakis on 9/29/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMIndividualItem.h"


#define kReferenceKey @"Reference"
#define kUserIdKey @"UserID"
#define kTimestampKey @"Timestamp"
#define kNameKey @"Name"
#define kEmailAddressKey @"EmailAddress"


@implementation NMIndividualItem

- (instancetype)initWithProperties:(NSDictionary *)properties
{
	self = [super initWithProperties:properties];
	
	if (self) {
		_reference = [[properties objectOrNilForKey:kReferenceKey] copy];
		_userId = [[properties objectForKey:kUserIdKey] copy];
		_timestamp = [[properties dateOrNilForKey:kTimestampKey] copy];
		_name = [[properties objectOrNilForKey:kNameKey] copy];
		_emailAddress = [[properties objectOrNilForKey:kEmailAddressKey] copy];
	}
	
	return self;
}

- (NSMutableDictionary *)properties
{
	NSMutableDictionary *properties = [super properties];
	[properties setObjectOrNil:_reference forKey:kReferenceKey];
	[properties setObjectOrNil:_userId forKey:kUserIdKey];
	[properties setObjectOrNil:[_timestamp stringRFC3339] forKey:kTimestampKey];
	[properties setObjectOrNil:_name forKey:kNameKey];
	[properties setObjectOrNil:_emailAddress forKey:kEmailAddressKey];

	return properties;
}

@end
