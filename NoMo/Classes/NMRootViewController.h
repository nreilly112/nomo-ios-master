//
//  NMRootViewController.h
//  NoMo
//
//  Created by Costas Harizakis on 14/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface NMRootViewController : UIViewController

@end


@interface UIViewController (NMRootViewController)

@property (nonatomic, weak, readonly) NMRootViewController *rootViewController;

@end
