//
//  NMExtensionItem.h
//  NoMo
//
//  Created by Costas Harizakis on 21/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMItem.h"


@interface NMExtensionItem : NMItem

@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSString *heading;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NMAmount *fundsBalance;
@property (nonatomic, copy) NMAmount *fundsHistoricAverage;
@property (nonatomic, strong) UIImage *fundsGraph;

@end
