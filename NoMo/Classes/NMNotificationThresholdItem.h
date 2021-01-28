//
//  NMNotificationThresholdItem.h
//  NoMo
//
//  Created by Costas Harizakis on 07/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMItem.h"


@interface NMNotificationThresholdItem : NMItem

@property (nonatomic, copy) NSString *currencyCode;
@property (nonatomic, assign) double minimumAllowedValue;
@property (nonatomic, assign) double maximumAllowedValue;

@end
