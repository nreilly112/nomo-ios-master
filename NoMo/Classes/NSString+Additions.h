//
//  NSString+Additions.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface NSString (Additions)

- (NSString *)stringByPrependingPathComponent:(NSString *)path;
- (NSString *)stringByPrependingMainBundleResourcePath;
- (NSString *)stringByPrependingDefaultDocumentDirectory;
- (NSString *)stringByPrependingDefaultCacheDirectory;

- (NSString *)stringByTrimmingWhitespaceCharacters;
- (NSString *)stringByTrimmingWhitespaceAndNewlineCharacters;

- (NSString *)stringByRemovingTrailingSlash;

- (NSString *)sentenceCapitalizedString;
- (NSString *)realSentenceCapitalizedString;

+ (NSString *)randomStringWithMinLength:(NSUInteger)minLength maxLength:(NSUInteger)maxLength;
+ (NSString *)shortStringExpressionForInteger:(NSUInteger)count;
+ (NSString *)stringForAmount:(NMAmount *)amount;
+ (NSString *)stringForAmountValue:(double)value withCurrencyCode:(NSString *)currencyCode;

@end
