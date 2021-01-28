//
//  NMSessionStateModel.h
//  NoMo
//
//  Created by Costas Harizakis on 10/5/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoModel.h"


@interface NMSessionStateModel : NoMoModel <NoMoLoadModel>

@property (nonatomic, assign) NSInteger numberOfVerifiedLoginAttempts;
@property (nonatomic, assign) NMSessionVerificationState verificationState;
@property (nonatomic, copy) NSError *verificationError;
@property (nonatomic, copy) NSDate *lastRefreshDate;

- (instancetype)initWithSession:(id<NMSession>)session;

@end
