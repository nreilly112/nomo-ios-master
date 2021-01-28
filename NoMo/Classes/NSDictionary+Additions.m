//
//  NSDictionary+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NSDictionary+Additions.h"
#import "NMSerializing.h"


@implementation NSDictionary (Additions)

- (instancetype)initWithJSONData:(NSData *)data
{
	__autoreleasing NSError *error;
	
	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	
	if (error) {
		NSLog(@"[NSDictionary::initWithJSONData] [%@]", error.description);
		return nil;
	}
	
	return [self initWithDictionary:dictionary];
}

- (instancetype)initWithJSONString:(NSString *)string
{
	__autoreleasing NSError *error;
	
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	
	if (error) {
		NSLog(@"[NSDictionary::initWithJSONData] [%@]", error.description);
		return nil;
	}
	
	return [self initWithDictionary:dictionary];
}

- (instancetype)initWithJSONContentsOfFile:(NSString *)path
{
	__autoreleasing NSError *error;

	NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath:path];
	[stream open];
	
	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithStream:stream options:0 error:&error];
	
	[stream close];
	
	if (error) {
		NSLog(@"[NSDictionary::initWithJSONContentsOfFile] [Path: %@, Error: %@]", path, error.description);
		return nil;
	}
	
	return [self initWithDictionary:dictionary];
}

+ (instancetype)dictionaryWithJSONData:(NSData *)data
{
	return [[NSDictionary alloc] initWithJSONData:data];
}

+ (instancetype)dictionaryWithJSONString:(NSString *)string
{
	return [[NSDictionary alloc] initWithJSONString:string];
}

+ (instancetype)dictionaryWithJSONContentsOfFile:(NSString *)path
{
	return [[NSDictionary alloc] initWithJSONContentsOfFile:path];
}

- (NSData *)JSONData
{
	__autoreleasing NSError *error;
	
	NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
	
	if (error) {
		NSLog(@"[NSDictionary::JSONData] [%@]", error.description);
		return nil;
	}
	
	return data;
}

- (BOOL)writeToJSONFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile
{
	NSData *data = [self JSONData];

	return [data writeToFile:path atomically:YES];
}

- (BOOL)writeToJSONFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile error:(NSError * __autoreleasing *)error
{
	NSData *data = [self JSONData];
	NSDataWritingOptions options = 0;
	
	if (useAuxiliaryFile) {
		options = NSDataWritingAtomic;
	}

	return [data writeToFile:path options:options error:error];
}

- (BOOL)containsKey:(NSString *)key
{
	if ([self objectForKey:key]) {
		return YES;
	}
	
	return NO;
}

- (id)objectOrNilForKey:(id)key
{
	return [self objectOrNilForKey:key notFound:nil];
}

- (id)objectOrNilForKey:(id)key notFound:(id)notFoundObject
{
	id object = [self objectForKey:key];
	
	if (object == nil) {
		return notFoundObject;
	}
	else if ([object isKindOfClass:[NSNull class]]) {
		return nil;
	}
	else {
		return object;
	}
}

- (NSInteger)integerValueOrZeroForKey:(id)key
{
	return [self integerValueOrZeroForKey:key notFound:0];
}

- (NSInteger)integerValueOrZeroForKey:(id)key notFound:(NSInteger)notFoundValue
{
	id value = [self objectOrNilForKey:key];
	
	if (value == nil) {
		return notFoundValue;
	}
	else if ([value isKindOfClass:[NSNumber class]]) {
		return [value integerValue];
	}
	else {
		return [value integerValue];
	}
}

- (NSUInteger)unsignedIntegerValueOrZeroForKey:(id)key
{
	return [self unsignedIntegerValueOrZeroForKey:key notFound:0];
}

- (NSUInteger)unsignedIntegerValueOrZeroForKey:(id)key notFound:(NSUInteger)notFoundValue
{
	id value = [self objectOrNilForKey:key];
	
	if (value == nil) {
		return notFoundValue;
	}
	else if ([value isKindOfClass:[NSNumber class]]) {
		return [value unsignedIntegerValue];
	}
	else {
		return [value unsignedIntegerValue];
	}
}

- (double)doubleValueOrZeroForKey:(id)key
{
	return [self doubleValueOrZeroForKey:key notFound:0.0];
}

- (double)doubleValueOrZeroForKey:(id)key notFound:(double)notFoundValue
{
	id value = [self objectOrNilForKey:key];
	
	if (value == nil) {
		return notFoundValue;
	}
	else if ([value isKindOfClass:[NSNumber class]]) {
		return [value doubleValue];
	}
	else {
		return [value doubleValue];
	}
}

- (NSURL *)URLOrNilForKey:(id)key
{
	return [self URLOrNilForKey:key notFound:nil];
}

- (NSURL *)URLOrNilForKey:(id)key notFound:(NSURL *)notFoundURL
{
	id value = [self objectOrNilForKey:key];
	
	if (value == nil) {
		return notFoundURL;
	}
	else if ([value isKindOfClass:[NSURL class]]) {
		return value;
	}
	else if ([value isKindOfClass:[NSString class]]) {
		return [NSURL URLWithString:value];
	}
	else {
		return nil;
	}
}

- (NSDate *)dateOrNilForKey:(id)key
{
	return [self dateOrNilForKey:key notFound:nil];
}

- (NSDate *)dateOrNilForKey:(id)key notFound:(NSDate *)notFoundDate
{
	id value = [self objectOrNilForKey:key];
	
	if (value == nil) {
		return notFoundDate;
	}
	else if ([value isKindOfClass:[NSDate class]]) {
		return value;
	}
	else if ([value isKindOfClass:[NSString class]]) {
		return [NSDate dateWithRFC3339String:value];
	}
	else {
		return nil;
	}
}

- (NSMutableDictionary *)dictionaryByRemovingNilValues
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	
	for (NSString *key in self.allKeys) {
		id value = [self objectOrNilForKey:key];
		
		if (value) {
			[dictionary setObject:value forKey:key];
		}
	}
	
	return dictionary;
}

@end


@implementation NSDictionary (NMSerializing)

- (NSMutableDictionary *)dictionaryByConvertingItemsToProperties
{
	NSMutableDictionary *dictionaryOfProperties = [NSMutableDictionary dictionaryWithCapacity:self.count];
	
	for (NSString *key in self) {
		id value = [self objectForKey:key];
		
		if ([value conformsToProtocol:@protocol(NMSerializing)]) {
			id<NMSerializing> item = value;
			[dictionaryOfProperties setObject:item.properties forKey:key];
		}
		else if ([value isKindOfClass:[NSArray class]]) {
			NSArray *arrayOfProperties = [value arrayByConvertingItemsToProperties];
			[dictionaryOfProperties setObject:arrayOfProperties forKey:key];
		}
	}
	
	return dictionaryOfProperties;
}

- (NSMutableDictionary *)dictionaryByConvertingPropertiesToItemsOfKind:(Class)class
{
	if (![class conformsToProtocol:@protocol(NMSerializing)]) {
		return nil;
	}
	
	NSMutableDictionary *dictionaryOfItems = [NSMutableDictionary dictionaryWithCapacity:self.count];
	
	for (NSString *key in self) {
		id value = [self objectForKey:key];
		
		if ([value isKindOfClass:[NSDictionary class]]) {
			id<NMSerializing> item = [class alloc];
			item = [item initWithProperties:value];
			[dictionaryOfItems setObject:item forKey:key];
		}
		else if ([value isKindOfClass:[NSArray class]]) {
			NSArray *items = [value arrayByConvertingPropertiesToItemsOfKind:class];
			[dictionaryOfItems setObject:items forKey:key];
		}
	}
	
	return dictionaryOfItems;
}

- (id)itemOfKind:(Class)class
{
	if (![class conformsToProtocol:@protocol(NMSerializing)]) {
		return nil;
	}
	
	id<NMSerializing> item = [class alloc];
	item = [item initWithProperties:self];
	
	return item;
}

@end


