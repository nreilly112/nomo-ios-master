//
//  NMAccessTokenItem.h
//  NoMo
//
//  Created by Costas Harizakis on 10/18/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMItem.h"


@interface NMAccessTokenItem : NMItem

@property (nonatomic, copy, readonly) NSString *tokenType;
@property (nonatomic, copy, readonly) NSString *accessTokenString;
@property (nonatomic, copy, readonly) NSString *refreshTokenString;
@property (nonatomic, copy, readonly) NSDate *lastRefreshDate;
@property (nonatomic, copy, readonly) NSDate *expirationDate;
@property (nonatomic, copy, readonly) NSString *scope;

- (BOOL)isExpired;

@end
