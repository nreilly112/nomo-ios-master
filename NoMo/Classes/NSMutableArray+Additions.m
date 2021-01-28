//
//  NSMutableArray+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NSMutableArray+Additions.h"


@implementation NSMutableArray (Additions)

- (instancetype)initWithJSONData:(NSData *)data
{
	__autoreleasing NSError *error;
	
	NSJSONReadingOptions options = NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves;
	NSMutableArray *array = [NSJSONSerialization JSONObjectWithData:data options:options error:&error];
	
	if (error) {
		NSLog(@"[NSMutableArray::initWithJSONData] [%@]", error.description);
		return nil;
	}
	
	return [self initWithArray:array];
}

- (instancetype)initWithJSONContentsOfFile:(NSString *)path
{
	__autoreleasing NSError *error;
	
	NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath:path];
	[stream open];
	
	NSJSONReadingOptions options = NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves;
	NSMutableArray *array = [NSJSONSerialization JSONObjectWithStream:stream options:options  error:&error];
	
	[stream close];
	
	if (error) {
		NSLog(@"[NSMutableArray::initWithJSONContentsOfFile] [Path: %@, Error: %@]", path, error.description);
		NSLog(@"\n%@", [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]);

		return nil;
	}
	
	return [self initWithArray:array];
}

+ (instancetype)arrayWithJSONData:(NSData *)data
{
	return [[NSMutableArray alloc] initWithJSONData:data];
}

+ (instancetype)arrayWithJSONContentsOfFile:(NSString *)path
{
	return [[NSMutableArray alloc] initWithJSONContentsOfFile:path];
}

+ (instancetype)nonRetainingArray
{
	return (__bridge_transfer NSMutableArray *)CFArrayCreateMutable(nil, 0, nil);
}

- (void)addObject:(id)object withCondition:(BOOL)condition
{
	if (condition) {
		[self addObject:object];
	}
}

- (void)addObjectOrNil:(id)value
{
	[self addObject:value ?: [NSNull null]];
}

- (void)addObjectOrNil:(id)value withCondition:(BOOL)condition
{
	if (condition) {
		[self addObjectOrNil:value];
	}
}

- (void)insertObjectOrNil:(id)value atIndex:(NSUInteger)index
{
	[self insertObject:value ?: [NSNull null] atIndex:index];
}

- (void)removeNilObjects
{
	for (NSUInteger index = self.count; 0 < index; --index) {
		id object = [self objectOrNilAtIndex:index - 1];
		
		if (object == nil) {
			[self removeObjectAtIndex:index - 1];
		}
	}
}

@end
