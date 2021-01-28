//
//  NSMutableDictionary+Additions.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface NSMutableDictionary (Additions)

- (instancetype)initWithJSONData:(NSData *)data;
- (instancetype)initWithJSONContentsOfFile:(NSString *)path;

+ (instancetype)dictionaryWithJSONData:(NSData *)data;
+ (instancetype)dictionaryWithJSONContentsOfFile:(NSString *)path;

- (void)setObjectOrNil:(id)value forKey:(id)key;
- (void)setIntegerValue:(NSInteger)value forKey:(id)key;
- (void)setUnsignedIntegerValue:(NSUInteger)value forKey:(id)key;
- (void)setDoubleValue:(double)value forKey:(id)key;

@end
