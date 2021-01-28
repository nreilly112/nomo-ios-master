//
//  NMSummaryMessagesModel.h
//  NoMo
//
//  Created by Costas Harizakis on 11/1/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMModel.h"


@interface NMSummaryMessagesModel : NMModel

- (NSString *)textWithPersona:(NMApplicationPersona)persona forAmount:(NMAmount *)amount;

@end


@interface NMSummaryMessagesModel (Global)

+ (instancetype)summaryHeadingsModel;
+ (instancetype)summaryCommentsModel;

@end
