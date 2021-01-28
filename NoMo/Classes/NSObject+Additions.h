//
//  NSObject+Additions.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface NSObject (Additions)

- (BOOL)isArrayWithObjectsOfKind:(Class)class;

- (void)performBlockOnMainThread:(void (^)(void)) block;
- (void)performBlockOnMainThread:(void (^)(void)) block afterDelay:(NSTimeInterval)delay;

@end
