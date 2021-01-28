//
//  NMOAuth2Credentials.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@protocol NMOAuth2Credentials <NSObject, NSCopying>

@property (nonatomic, copy, readonly) NSString *clientId;
@property (nonatomic, copy, readonly) NSString *clientSecret;

@end


@interface NMOAuth2Credentials : NSObject <NMOAuth2Credentials>

@property (nonatomic, copy, readonly) NSString *clientId;
@property (nonatomic, copy, readonly) NSString *clientSecret;

+ (instancetype)credentialsWithClientId:(NSString *)clientId
						   clientSecret:(NSString *)clientSecret;

@end
