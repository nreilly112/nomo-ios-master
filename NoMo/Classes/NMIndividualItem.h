//
//  NMIndividualItem.h
//  NoMo
//
//  Created by Costas Harizakis on 9/29/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMItem.h"


@interface NMIndividualItem : NMItem

@property (nonatomic, copy) NSString *reference;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSDate *timestamp;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *emailAddress;

@end
