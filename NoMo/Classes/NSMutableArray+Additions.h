//
//  NSMutableArray+Additions.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface NSMutableArray (Additions)

- (instancetype)initWithJSONData:(NSData *)data;
- (instancetype)initWithJSONContentsOfFile:(NSString *)path;

+ (instancetype)arrayWithJSONData:(NSData *)data;
+ (instancetype)arrayWithJSONContentsOfFile:(NSString *)path;

+ (instancetype)nonRetainingArray;

- (void)addObject:(id)object withCondition:(BOOL)condition;

- (void)addObjectOrNil:(id)value;
- (void)addObjectOrNil:(id)value withCondition:(BOOL)condition;
- (void)insertObjectOrNil:(id)value atIndex:(NSUInteger)index;

- (void)removeNilObjects;

@end
