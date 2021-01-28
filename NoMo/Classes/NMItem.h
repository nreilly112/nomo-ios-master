//
//  NMItem.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMSerializing.h"


@interface NMItem : NSObject <NMSerializing, NSCopying>

+ (instancetype)itemWithProperties:(NSDictionary *)properties;

@end
