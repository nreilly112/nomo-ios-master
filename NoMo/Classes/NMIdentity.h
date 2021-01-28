//
//  NMIdentity.h
//  NoMo
//
//  Created by Costas Harizakis on 9/30/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@protocol NMIdentity <NSObject>

//@property (nonatomic, copy, readonly) NSString *name;
//@property (nonatomic, copy, readonly) NSString *domain;
@property (nonatomic, copy, readonly) NSString *clientSecret;
@property (nonatomic, copy, readonly) NSString *clientId;
@property (nonatomic, copy, readonly) NSString *grantType;
@property (nonatomic, copy, readonly) NSString *scope;

@end


@interface NMIdentity : NSObject <NMIdentity>

//@property (nonatomic, copy, readonly) NSString *name;
//@property (nonatomic, copy, readonly) NSString *domain;
@property (nonatomic, copy, readonly) NSString *clientSecret;
@property (nonatomic, copy, readonly) NSString *clientId;
@property (nonatomic, copy, readonly) NSString *grantType;
@property (nonatomic, copy, readonly) NSString *scope;

+ (instancetype)identityWithGrantType:(NSString *)grantType
                             clientId:(NSString *)clientId
                             clientSecret:(NSString *)clientSecret
                             scope:(NSString *)scope;

@end
