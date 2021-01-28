//
//  NMBinder.h
//  NoMo
//
//  Created by Costas Harizakis on 9/24/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface NMBinder : NSObject

@property (nonatomic, strong) IBOutlet id object;
@property (nonatomic, copy) IBInspectable NSString *key;

@property (nonatomic, strong) id value;

- (instancetype)initWithObject:(id)object key:(NSString *)key;

- (void)didChangeValue;

@end
