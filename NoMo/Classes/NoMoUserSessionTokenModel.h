//
//  NoMoUserSessionTokenModel.h
//  NoMo
//
//  Created by Costas Harizakis on 09/12/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMModel.h"
#import "NMIdentity.h"


@interface NoMoUserSessionTokenModel : NMModel

@property (nonatomic, strong, readonly) id<NMIdentity> userIdentity;

@property (nonatomic, copy) NSString *tokenString;
@property (nonatomic, copy) NSString *expiresIn;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *widgetUrl;

- (instancetype)initForUserWithIdentity:(id<NMIdentity>)userIdentity;

- (void)invalidate;

- (BOOL)canLoad;
- (BOOL)load;
- (void)cancelLoad;

@end
