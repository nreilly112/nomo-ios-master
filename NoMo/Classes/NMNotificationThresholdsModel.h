//
//  NMNotificationThresholdsModel.h
//  NoMo
//
//  Created by Costas Harizakis on 07/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMModel.h"


@interface NMNotificationThresholdsModel : NMModel

- (double)minimumAllowedValueForCurrencyCode:(NSString *)currencyCode;
- (double)maximumAllowedValueForCurrencyCode:(NSString *)currencyCode;

@end


@interface NMNotificationThresholdsModel (Global)

+ (instancetype)defaultModel;

@end
