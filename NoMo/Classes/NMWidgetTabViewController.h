//
//  NMWidgetTabViewController.h
//  NoMo
//
//  Created by Marta on 23.08.2018.
//  Copyright © 2018 MiiCard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMWidgetTabViewController.h"

@class NMWidgetTabViewController;

@protocol NMWidgetTabViewControllerDelegate <NSObject>

@end

@interface NMWidgetTabViewController : UIViewController

@property (nonatomic, weak) id<NMWidgetTabViewControllerDelegate> delegate;
@property (nonatomic, assign) NSString *urlAddress;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
