//
//  NSData+Additions.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface NSData (Additions)

+ (instancetype)dataWithHexString:(NSString *)hex;

- (NSString *)hexString;

@end
