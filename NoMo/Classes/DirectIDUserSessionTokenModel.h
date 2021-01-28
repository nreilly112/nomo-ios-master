//
//  DirectIDUserSessionTokenModel.h
//  NoMo
//
//  Created by Costas Harizakis on 9/27/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMModel.h"
#import "NMIdentity.h"


@interface DirectIDUserSessionTokenModel : NMModel

@property (nonatomic, strong, readonly) id<NMIdentity> userIdentity;
@property (nonatomic, assign) BOOL authenticationEnabled;
@property (nonatomic, assign) BOOL refreshEnabled;

@property (nonatomic, copy, readonly) NSString *tokenString;
@property (nonatomic, copy, readonly) NSString *reference;

- (instancetype)initForUserWithIdentity:(id<NMIdentity>)userIdentity;

- (void)invalidate;

- (BOOL)canLoad;
- (BOOL)load;
- (void)cancelLoad;

@end
