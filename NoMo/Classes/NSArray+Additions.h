//
//  NSArray+Additions.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface NSArray (Additions)

- (instancetype)initWithJSONData:(NSData *)data;
- (instancetype)initWithJSONContentsOfFile:(NSString *)path;

+ (instancetype)arrayWithJSONData:(NSData *)data;
+ (instancetype)arrayWithJSONContentsOfFile:(NSString *)path;

- (NSData *)JSONData;
- (BOOL)writeToJSONFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
- (BOOL)writeToJSONFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile error:(NSError * __autoreleasing *)error;

- (id)objectOrNilAtIndex:(NSUInteger)index;
- (id)firstObjectOrNil;
- (id)lastObjectOrNil;

- (BOOL)containsObjectOfKind:(Class)class;
- (BOOL)containsOnlyObjectsOfKind:(Class)class;

- (NSMutableArray *)filteredArrayWithObjectsOfKind:(Class)class;
- (NSMutableArray *)filteredArrayWithObjectsConformingToProtocol:(Protocol *)protocol;

- (NSArray *)arrayByRemovingObject:(id)object;
- (NSArray *)arrayByReversingObjects;

- (NSUInteger)indexOfFirstNonNilValue;
- (NSUInteger)indexOfFirstNonNilValueAfterIndex:(NSUInteger)startIndex;
- (NSUInteger)indexOfFirstNilValue;
- (NSUInteger)indexOfFirstNilValueAfterIndex:(NSUInteger)startIndex;

@end


@interface NSArray (NMSerializing)

- (NSMutableArray *)arrayByConvertingItemsToProperties;
- (NSMutableArray *)arrayByConvertingPropertiesToItemsOfKind:(Class)class;

@end


@interface NSArray (Aggregation)

- (double)minimumDoubleValue;
- (double)maximumDoubleValue;

@end
