//
//  NMSessionTokenModel.h
//  NoMo
//
//  Created by Costas Harizakis on 08/12/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMModel.h"
#import "NMSecurityContext.h"
#import "NMToken.h"


@interface DirectIDAuthenticationModel : NMModel

@property (nonatomic, strong, readonly) NMSecurityContext *securityContext;

@property (nonatomic, copy, readonly) NSString *tokenString;
@property (nonatomic, copy, readonly) NSDate *expirationDate;

- (instancetype)initWithSecurityContext:(NMSecurityContext *)securityContext;

- (void)invalidate;

- (BOOL)canLoad;
- (BOOL)load;
- (void)cancelLoad;

+ (instancetype)sharedModel;

@end
