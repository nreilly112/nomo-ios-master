//
//  NMObservablePropertyBinder.h
//  NoMo
//
//  Created by Costas Harizakis on 9/24/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMBinder.h"


@interface NMObservablePropertyBinder : NMBinder

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, copy) IBInspectable NSString *observablePropertyName;

@end
