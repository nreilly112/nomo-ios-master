//
//  NSMutableDictionary+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NSMutableDictionary+Additions.h"


@implementation NSMutableDictionary (Additions)

- (instancetype)initWithJSONData:(NSData *)data
{
	__autoreleasing NSError *error;
	
	NSJSONReadingOptions options = NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves;
	NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:options error:&error];
	
	if (error) {
		NSLog(@"[NSMutableDictionary::initWithJSONData] [%@]", error.description);
		return nil;
	}
	
	return [self initWithDictionary:dictionary];
}

- (instancetype)initWithJSONContentsOfFile:(NSString *)path
{
	__autoreleasing NSError *error;

	NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath:path];
	[stream open];
	
	NSJSONReadingOptions options = NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves;
	NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithStream:stream options:options error:&error];
	
	[stream close];
	
	if (error) {
		NSLog(@"[NSMutableDictionary::initWithJSONContentsOfFile] [Path: %@, Error: %@]", path, error.description);
		return nil;
	}
	
	return [self initWithDictionary:dictionary];
}

+ (instancetype)dictionaryWithJSONData:(NSData *)data
{
	return [[NSMutableDictionary alloc] initWithJSONData:data];
}

+ (instancetype)dictionaryWithJSONContentsOfFile:(NSString *)path
{
	return [[NSMutableDictionary alloc] initWithJSONContentsOfFile:path];
}

- (void)setObjectOrNil:(id)value forKey:(id)key
{
	[self setObject:value ?: [NSNull null] forKey:key];
}

- (void)setIntegerValue:(NSInteger)value forKey:(id)key
{
	[self setObject:[NSNumber numberWithInteger:value] forKey:key];
}

- (void)setUnsignedIntegerValue:(NSUInteger)value forKey:(id)key
{
	[self setObject:[NSNumber numberWithUnsignedInteger:value] forKey:key];
}

- (void)setDoubleValue:(double)value forKey:(id)key
{
	[self setObject:[NSNumber numberWithDouble:value] forKey:key];
}

@end
