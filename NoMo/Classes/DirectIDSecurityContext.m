//
//  DirectIDSecurityContext.m
//  NoMo
//
//  Created by Costas Harizakis on 10/3/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "DirectIDSecurityContext.h"


@implementation DirectIDSecurityContext

#pragma mark - [ Constructors (Static) ]

+ (instancetype)defaultContext
{
	static DirectIDSecurityContext *instance;
	static dispatch_once_t once;
	
	dispatch_once(&once, ^(void) {
		instance = [[DirectIDSecurityContext alloc] init];
	});
	
	return instance;
}

@end
