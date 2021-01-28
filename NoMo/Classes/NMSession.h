//
//  NMSession.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMIdentity.h"


extern NSString * const kNMSessionDidOpenNotification;
extern NSString * const kNMSessionDidCloseNotification;
extern NSString * const kNMSessionDidVerifyNotification;
extern NSString * const kNMSessionDidFailVerifyNotification;
extern NSString * const kNMSessionDidChangeNotification;

extern NSString * const kNMSessionParameterNumberOfLoginAttempts;
extern NSString * const kNMSessionParameterNumberOfFailedLoginAttempts;
extern NSString * const kNMSessionParameterVerificationState;

@protocol NMSession <NSObject>

@property (nonatomic, strong, readonly) id<NMIdentity> userIdentity;
@property (nonatomic, copy, readonly) NSString *sessionId;

@property (nonatomic, assign, readonly) BOOL isOpen;
@property (nonatomic, assign, readonly) BOOL isVerified;

@end


@interface NMSession : NSObject <NMSession>

- (void)openForUserWithIdentity:(id<NMIdentity>)userIdentity
                      sessionId:(NSString*)sessionId
					 parameters:(NSDictionary *)parameters;
- (void)openExisting;
- (void)close;

- (void)setNeedsVerification;
- (void)verifyIfNeeded;

- (void)sessionDidOpen;
- (void)sessionDidClose;
- (void)sessionDidVerify;
- (void)sessionDidFailVerifyWithError:(NSError *)error;
- (void)sessionDidChange;

@end


@interface NMSession (Global)

+ (instancetype)sharedSession;

@end
