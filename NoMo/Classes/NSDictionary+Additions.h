//
//  NSDictionary+Additions.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface NSDictionary (Additions)

- (instancetype)initWithJSONData:(NSData *)data;
- (instancetype)initWithJSONString:(NSString *)string;
- (instancetype)initWithJSONContentsOfFile:(NSString *)path;

+ (instancetype)dictionaryWithJSONData:(NSData *)data;
+ (instancetype)dictionaryWithJSONString:(NSString *)string;
+ (instancetype)dictionaryWithJSONContentsOfFile:(NSString *)path;

- (NSData *)JSONData;
- (BOOL)writeToJSONFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
- (BOOL)writeToJSONFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile error:(NSError * __autoreleasing *)error;

- (BOOL)containsKey:(NSString *)key;

- (id)objectOrNilForKey:(id)key;
- (id)objectOrNilForKey:(id)key notFound:(id)notFoundObject;
- (NSInteger)integerValueOrZeroForKey:(id)key;
- (NSInteger)integerValueOrZeroForKey:(id)key notFound:(NSInteger)notFoundValue;
- (NSUInteger)unsignedIntegerValueOrZeroForKey:(id)key;
- (NSUInteger)unsignedIntegerValueOrZeroForKey:(id)key notFound:(NSUInteger)notFoundValue;
- (double)doubleValueOrZeroForKey:(id)key;
- (double)doubleValueOrZeroForKey:(id)key notFound:(double)notFoundValue;
- (NSURL *)URLOrNilForKey:(id)key;
- (NSURL *)URLOrNilForKey:(id)key notFound:(NSURL *)notFoundURL;
- (NSDate *)dateOrNilForKey:(id)key;
- (NSDate *)dateOrNilForKey:(id)key notFound:(NSDate *)notFoundDate;

- (NSMutableDictionary *)dictionaryByRemovingNilValues;

@end


@interface NSDictionary (NMSerializing)

- (NSMutableDictionary *)dictionaryByConvertingItemsToProperties;
- (NSMutableDictionary *)dictionaryByConvertingPropertiesToItemsOfKind:(Class)class;

- (id)itemOfKind:(Class)class;

@end
