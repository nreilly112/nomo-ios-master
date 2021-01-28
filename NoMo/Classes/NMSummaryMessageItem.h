//
//  NMSummaryMessageItem.h
//  NoMo
//
//  Created by Costas Harizakis on 11/1/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMItem.h"


@interface NMSummaryMessageItem : NMItem

@property (nonatomic, assign) NMApplicationPersona persona;
@property (nonatomic, copy) NSString *currencyCode;
@property (nonatomic, assign) double minimumValue;
@property (nonatomic, assign) double maximumValue;
@property (nonatomic, copy) NSString *text;

@end


@interface NMSummaryMessageItem (Compare)

- (BOOL)canUseWithPersona:(NMApplicationPersona)persona forAmount:(NMAmount *)amount;

@end
