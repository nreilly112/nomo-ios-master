//
//  NoMoSecurityContext.m
//  NoMo
//
//  Created by Costas Harizakis on 10/3/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoSecurityContext.h"


@implementation NoMoSecurityContext

#pragma mark - [ Constructors (Static) ]

+ (instancetype)defaultContext
{
	static NoMoSecurityContext *instance;
	static dispatch_once_t once;
	
	dispatch_once(&once, ^(void) {
		instance = [[NoMoSecurityContext alloc] init];
	});
	
	return instance;
}

@end
