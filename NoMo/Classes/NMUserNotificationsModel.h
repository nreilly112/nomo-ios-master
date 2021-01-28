//
//  NMUserNotificationsModel.h
//  NoMo
//
//  Created by Costas Harizakis on 9/24/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoModel.h"


@interface NMUserNotificationsModel : NoMoModel <NoMoLoadModel, NoMoSaveModel>

@property (nonatomic, copy) NSData *deviceToken;

+ (instancetype)sharedModel;

@end
