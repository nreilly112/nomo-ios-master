//
//  NMUserSettingsViewModel.h
//  NoMo
//
//  Created by Costas Harizakis on 9/24/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMViewModel.h"


@interface NMUserSettingsViewModel : NMViewModel

@property (nonatomic, copy) NSString *preferredCurrencyCode;
@property (nonatomic, assign) CGFloat incrementNotificationThreshold;
@property (nonatomic, assign) CGFloat decrementNotificationThreshold;
@property (nonatomic, assign) NSUInteger applicationPersona;
@property (nonatomic, assign) BOOL notificationsEnabled;
@property (nonatomic, assign) BOOL includeOverdraft;

@end
