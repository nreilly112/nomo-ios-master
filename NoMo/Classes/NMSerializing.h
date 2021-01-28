//
//  NMSerializing.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@protocol NMSerializing <NSObject>

@property (nonatomic, copy, readonly) NSMutableDictionary *properties;

- (instancetype)initWithProperties:(NSDictionary *)properties;

@end
