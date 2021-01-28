//
//  NSString+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NSString+Additions.h"


@implementation NSString (Additions)

- (NSString *)stringByPrependingPathComponent:(NSString *)path
{
	return [path stringByAppendingPathComponent:self];
}

- (NSString *)stringByPrependingMainBundleResourcePath
{
	NSString *mainBundleResourcePath = [[NSBundle mainBundle] resourcePath];
	
	return [self stringByPrependingPathComponent:mainBundleResourcePath];
}

- (NSString *)stringByPrependingDefaultDocumentDirectory
{
	NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *defaultDocumentDirectory = [documentDirectories objectAtIndex:0];
	
	return [self stringByPrependingPathComponent:defaultDocumentDirectory];
}

- (NSString *)stringByPrependingDefaultCacheDirectory
{
	NSArray *cacheDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *defaultCacheDirectory = [cacheDirectories objectAtIndex:0];
	
	return [self stringByPrependingPathComponent:defaultCacheDirectory];
}

- (NSString *)stringByTrimmingWhitespaceCharacters
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)stringByTrimmingWhitespaceAndNewlineCharacters
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)stringByRemovingTrailingSlash
{
	if ([self hasSuffix:@"/"]) {
		return [self substringToIndex:(self.length - 1)];
	}
	
	return self;
}

- (NSString *)sentenceCapitalizedString
{
	if (![self length]) {
		return [NSString string];
	}
	
	NSString *uppercase = [[self substringToIndex:1] uppercaseString];
	NSString *lowercase = [[self substringFromIndex:1] lowercaseString];
	
	return [uppercase stringByAppendingString:lowercase];
}

- (NSString *)realSentenceCapitalizedString
{
	__block NSMutableString *mutableSelf = [NSMutableString stringWithString:self];
	
	[self enumerateSubstringsInRange:NSMakeRange(0, [self length])
							 options:NSStringEnumerationBySentences
						  usingBlock:^(NSString *sentence, NSRange sentenceRange, NSRange enclosingRange, BOOL *stop) {
							  [mutableSelf replaceCharactersInRange:sentenceRange withString:[sentence sentenceCapitalizedString]];
						  }
	 ];
	
	return [NSString stringWithString:mutableSelf];
}

+ (NSString *)randomStringWithMinLength:(NSUInteger)minLength maxLength:(NSUInteger)maxLength
{
	NSString *sample = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris ipsum arcu, consequat non orci ultrices, feugiat maximus ex. Praesent elementum facilisis luctus. Integer semper, eros id vestibulum dignissim, nulla purus ultrices elit, sit amet interdum nibh lectus ac mi. Vestibulum eleifend malesuada sollicitudin. Suspendisse quis erat mauris. Sed nec urna et nibh tincidunt egestas. Sed ut sapien id nibh lobortis mollis.";

	NSMutableString *randomString = [NSMutableString stringWithString:sample];
	
	minLength = MAX(0, minLength);
	maxLength = MAX(minLength, maxLength);
	
	while (randomString.length < maxLength) {
		[randomString appendString:@" "];
		[randomString appendString:sample];
	}
	
	NSUInteger length = minLength + arc4random_uniform((int)(maxLength - minLength));
	NSString *result = [randomString substringToIndex:length];
	
	return result;
}

+ (NSString *)shortStringExpressionForInteger:(NSUInteger)count
{
	if (1000000 <= count) {
		return [NSString stringWithFormat:@">%dM", (int)count / 1000000];
	}
	else if (100000 <= count) {
		return [NSString stringWithFormat:@"%0.1fK", (int)count / 100000.0];
	}
	else if (1000 <= count) {
		return [NSString stringWithFormat:@"%0.1fK", (int)count / 1000.0];
	}
	else if (0 < count) {
		return [NSString stringWithFormat:@"%d", (int)count];
	}
	else {
		return @"-";
	}
}

+ (NSString *)stringForAmount:(NMAmount *)amount
{
	return [self stringForAmountValue:amount.value withCurrencyCode:amount.currencyCode];
}

+ (NSString *)stringForAmountValue:(double)value withCurrencyCode:(NSString *)currencyCode
{
	NSNumber *number = [NSNumber numberWithDouble:value];
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[currencyFormatter setCurrencyCode:currencyCode];

	return [currencyFormatter stringFromNumber:number];
}

@end
