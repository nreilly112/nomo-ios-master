//
//  NMToken.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@protocol NMToken <NSObject, NSCopying>

@property (nonatomic, copy, readonly) NSString *tokenString;
@property (nonatomic, copy, readonly) NSDate *expirationDate;

- (BOOL)isExpired;

@end


@interface NMToken : NSObject <NMToken>

@property (nonatomic, copy, readonly) NSString *tokenString;
@property (nonatomic, copy, readonly) NSDate *expirationDate;

+ (instancetype)tokenWithTokenString:(NSString *)tokenString
					  expirationDate:(NSDate *)expirationDate;

- (BOOL)isExpired;

@end


BOOL NMTokenIsValid(id<NMToken> token);