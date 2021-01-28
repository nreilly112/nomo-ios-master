//
//  NSRange+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NSRange+Additions.h"


BOOL NSRangeContains(NSRange range, NSUInteger index)
{
	return (range.location <= index) && (index < range.location + range.length);
}
