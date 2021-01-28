//
//  NSData+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NSData+Additions.h"


@implementation NSData (Additions)

+ (instancetype)dataWithHexString:(NSString *)hex
{
	char buf[3] = { 0, 0, 0 };

	unsigned char *bytes = malloc([hex length]/2);
	unsigned char *bp = bytes;
	
	for (NSUInteger i = 0; i < [hex length]; i += 2) {
		buf[0] = [hex characterAtIndex:i];
		buf[1] = [hex characterAtIndex:i+1];

		char *b2 = NULL;
		*bp++ = strtol(buf, &b2, 16);
	}
	
	return [NSData dataWithBytesNoCopy:bytes length:([hex length] / 2) freeWhenDone:YES];
}

- (NSString *)hexString
{
	const unsigned char *bytes = (const unsigned char *)[self bytes];
	NSMutableString *hexString = [NSMutableString stringWithCapacity:([self length] * 2)];
	
	for (int i = 0; i < [self length]; i += 1) {
		[hexString appendFormat:@"%02lx", (unsigned long)bytes[i]];
	}
	
	return [NSString stringWithString:hexString];
}

@end
