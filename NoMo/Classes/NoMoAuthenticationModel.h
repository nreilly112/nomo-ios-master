//
//  NoMoAuthenticationModel.h
//  NoMo
//
//  Created by Costas Harizakis on 10/18/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMModel.h"
#import "NMSession.h"


@interface NoMoAuthenticationModel : NMModel

@property (nonatomic, strong, readonly) id<NMSession> session;

@property (nonatomic, copy, readonly) NSString *accessTokenString;
@property (nonatomic, copy, readonly) NSDate *lastRefreshDate;
@property (nonatomic, copy, readonly) NSDate *expirationDate;

- (instancetype)initWithSession:(id<NMSession>)session;
+ (instancetype)modelWithSession:(id<NMSession>)session;

- (BOOL)isExpired;

- (BOOL)canLoad;
- (BOOL)load;
- (void)cancelLoad;
- (void)invalidate;

- (BOOL)canSave;
- (BOOL)save;
- (void)cancelSave;

+ (instancetype)sharedModel;

@end
