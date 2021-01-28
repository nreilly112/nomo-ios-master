//
//  AzureAuthenticationModel.h
//  NoMo
//
//  Created by Costas Harizakis on 9/27/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMModel.h"
#import "NMSecurityContext.h"
#import "NMOAuth2Credentials.h"
#import "NMToken.h"


@interface AzureAuthenticationModel : NMModel

@property (nonatomic, strong, readonly) NMSecurityContext *securityContext;
@property (nonatomic, copy, readonly) NSString *authority;

@property (nonatomic, copy) NSString *resource;
@property (nonatomic, copy) NMOAuth2Credentials *credentials;

@property (nonatomic, copy, readonly) NSString *tokenString;
@property (nonatomic, copy, readonly) NSDate *expirationDate;

- (instancetype)initWithSecurityContext:(NMSecurityContext *)securityContext
						 usingAuthority:(NSString *)authority;

- (void)invalidate;

- (BOOL)canLoad;
- (BOOL)load;
- (void)cancelLoad;

@end
