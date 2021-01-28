//
//  NMUserSettingsModel.h
//  NoMo
//
//  Created by Costas Harizakis on 9/26/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoModel.h"


@interface NMUserSettingsModel : NoMoModel <NoMoLoadModel, NoMoSaveModel>

@property (nonatomic, copy) NSString *preferredCurrencyCode;
@property (nonatomic, assign) CGFloat incrementNotificationThreshold;
@property (nonatomic, assign) CGFloat decrementNotificationThreshold;
@property (nonatomic, assign) NMApplicationPersona applicationPersona;
@property (nonatomic, assign) BOOL notificationsEnabled;
@property (nonatomic, assign) BOOL includeOverdraft;

+ (instancetype)sharedModel;

@end
