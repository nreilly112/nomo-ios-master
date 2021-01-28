//
//  NSArray+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NSArray+Additions.h"
#import "NMSerializing.h"


@implementation NSArray (Additions)

- (instancetype)initWithJSONData:(NSData *)data
{
	__autoreleasing NSError *error;
	
	NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	
	if (error) {
		NSLog(@"[NSArray::initWithJSONData] [%@]", error.description);
		return nil;
	}
	
	return [self initWithArray:array];
}

- (instancetype)initWithJSONContentsOfFile:(NSString *)path
{
	__autoreleasing NSError *error;

	NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath:path];
	[stream open];
	
	NSArray *array = [NSJSONSerialization JSONObjectWithStream:stream options:0 error:&error];
	
	[stream close];
	
	if (error) {
		NSLog(@"[NSArray::initWithJSONContentsOfFile] [Path: %@, Error: %@]", path, error.description);
		return nil;
	}

	return [self initWithArray:array];
}

+ (instancetype)arrayWithJSONData:(NSData *)data
{
	return [[NSArray alloc] initWithJSONData:data];
}

+ (instancetype)arrayWithJSONContentsOfFile:(NSString *)path
{
	return [[NSArray alloc] initWithJSONContentsOfFile:path];
}

- (NSData *)JSONData
{
	__autoreleasing NSError *error;
	
	NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
	
	if (error) {
		NSLog(@"[NSArray::JSONData] [%@]", error.description);
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

	return [data writeToFile:path options:NSDataWritingAtomic error:error];
}

- (id)objectOrNilAtIndex:(NSUInteger)index
{
	if (index < self.count) {
		id object = [self objectAtIndex:index];
		
		if ([object isKindOfClass:[NSNull class]]) {
			return nil;
		}

		return object;
	}
	
	return nil;
}

- (id)firstObjectOrNil
{
	if (0 < self.count) {
		return [self firstObject];
	}
	
	return nil;
}

- (id)lastObjectOrNil
{
	if (0 < self.count) {
		return [self lastObject];
	}
	
	return nil;
}

- (BOOL)containsObjectOfKind:(Class)class
{
	for (id object in self) {
		if ([object isKindOfClass:class]) {
			return YES;
		}
	}
	
	return NO;
}

- (BOOL)containsOnlyObjectsOfKind:(Class)class
{
	for (id object in self) {
		if (![object isKindOfClass:class]) {
			return NO;
		}
	}
	
	return YES;
}

- (NSMutableArray *)filteredArrayWithObjectsOfKind:(Class)class
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
	
	for (id object in self) {
		if ([object isKindOfClass:class]) {
			[array addObject:object];
		}
	}
	
	return array;
}

- (NSMutableArray *)filteredArrayWithObjectsConformingToProtocol:(Protocol *)protocol
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
	
	for (id object in self) {
		if ([object conformsToProtocol:protocol]) {
			[array addObject:object];
		}
	}
	
	return array;
}

- (NSArray *)arrayByRemovingObject:(id)object
{
	NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
		return !((object == evaluatedObject) || ([object isEqual:evaluatedObject]));
	}];
	NSArray *array = [self filteredArrayUsingPredicate:predicate];
	
	return array;
}

- (NSArray *)arrayByReversingObjects
{
	return [[self reverseObjectEnumerator] allObjects];
}

- (NSUInteger)indexOfFirstNonNilValue
{
	return [self indexOfFirstNonNilValueAfterIndex:0];
}

- (NSUInteger)indexOfFirstNonNilValueAfterIndex:(NSUInteger)startIndex
{
	for (NSUInteger index = startIndex; index < self.count; index += 1) {
		if ([self objectOrNilAtIndex:index] != nil) {
			return index;
		}
	}
	
	return NSNotFound;
}

- (NSUInteger)indexOfFirstNilValue
{
	return [self indexOfFirstNilValueAfterIndex:0];
}

- (NSUInteger)indexOfFirstNilValueAfterIndex:(NSUInteger)startIndex
{
	for (NSUInteger index = startIndex; index < self.count; index += 1) {
		if ([self objectOrNilAtIndex:index] == nil) {
			return index;
		}
	}
	
	return NSNotFound;
}

@end


@implementation NSArray (NMSerializing)

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


@implementation NSArray (Aggregation)

- (double)minimumDoubleValue
{
	double minimumValue = DBL_MAX;
	
	for (id element in self) {
		minimumValue = MIN(minimumValue, [element doubleValue]);
	}
	
	return minimumValue;
}
- (double)maximumDoubleValue
{
	double maximumValue = DBL_MIN;
	
	for (id element in self) {
		maximumValue = MAX(maximumValue, [element doubleValue]);
	}
	
	return maximumValue;
}

@end
