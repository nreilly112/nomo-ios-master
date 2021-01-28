//
//  NSDateFormatter+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NSDateFormatter+Additions.h"


@implementation NSDateFormatter (Additions)

+ (instancetype)dateFormatterRFC3339
{
	static dispatch_once_t once;
	static NSDateFormatter *instance;
	
	dispatch_once(&once, ^(void) {
		NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		//[formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZ"]; // NOTE: Temporary workaround to parse time zones.
		[formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
		[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		[formatter setLocale:locale];
		
		instance = formatter;
	});
	
	return instance;
}

@end
