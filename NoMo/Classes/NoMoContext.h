//
//  NoMoContext.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


extern NSString * const kActionAcceptTermsAndConditions;
extern NSString * const kActionDemonstrateSummary;
extern NSString * const kActionDemonstrateDetails;
extern NSString * const kActionDemonstrateSettings;


@interface NoMoContext : NSObject

@property (nonatomic, copy) NSString *currencyCode;
@property (nonatomic, assign) NMApplicationPersona applicationPersona;
@property (nonatomic, assign, readonly, getter = isNetworkAvailable) BOOL networkAvailable;

- (BOOL)hasPerformedActionNamed:(NSString *)actionName;
- (void)didPerformActionNamed:(NSString *)actionName;


+ (instancetype)sharedContext;

@end
