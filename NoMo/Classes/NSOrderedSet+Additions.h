//
//  NSOrderedSet+Additions.h
//  NoMo
//
//  Created by Costas Harizakis on 10/6/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface NSOrderedSet (NMSerializing)

- (NSMutableArray *)arrayByConvertingItemsToProperties;
- (NSMutableArray *)arrayByConvertingPropertiesToItemsOfKind:(Class)class;

@end
