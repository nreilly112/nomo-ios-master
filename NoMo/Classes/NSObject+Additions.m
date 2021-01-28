//
//  NSObject+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NSObject+Additions.h"


@implementation NSObject (Additions)

- (BOOL)isArrayWithObjectsOfKind:(Class)class
{
	if ([self isKindOfClass:[NSArray class]]) {
		NSArray *array = (NSArray *)self;

		if ([array containsOnlyObjectsOfKind:class]) {
			return YES;
		}
	}

	return NO;
}

- (void)performBlockOnMainThread:(void (^)(void))block
{
	[self performBlockOnMainThread:block afterDelay:0.0];
}

- (void)performBlockOnMainThread:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
	dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
	dispatch_queue_t queue = dispatch_get_main_queue();
	
	dispatch_after(time, queue, block);
}

@end
