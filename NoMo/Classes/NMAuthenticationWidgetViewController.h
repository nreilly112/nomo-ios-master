//
//  NMAuthenticationWidgetViewController.h
//  NoMo
//
//  Created by Costas Harizakis on 9/28/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@class NMAuthenticationWidgetViewController;

@protocol NMAuthenticationWidgetViewControllerDelegate <NSObject>

- (void)authenticationWidgetViewControllerDidComplete:(NMAuthenticationWidgetViewController *)viewController;
- (void)authenticationWidgetViewController:(NMAuthenticationWidgetViewController *)viewController didFailWithError:(NSError *)error;

@optional

- (void)authenticationWidgetViewControllerDidStartLoad:(NMAuthenticationWidgetViewController *)viewController;
- (void)authenticationWidgetViewControllerDidStopLoad:(NMAuthenticationWidgetViewController *)viewController;
- (void)authenticationWidgetViewControllerDidInitialize:(NMAuthenticationWidgetViewController *)viewController;

@end

@interface NMAuthenticationWidgetViewController : UIViewController

@property (nonatomic, assign, readonly) NSUInteger numberOfLoginAttempts;
@property (nonatomic, assign, readonly) NSUInteger numberOfFailedLoginAttempts;

@property (nonatomic, weak) id<NMAuthenticationWidgetViewControllerDelegate> delegate;

- (void)loadWithWidgetUrl:(NSString *)widgetUrl;
- (void)cancelLoad;

- (BOOL)isLoading;

- (void)didComplete;
- (void)didFailLoadWithError:(NSError *)error;
- (void)didStartLoad;
- (void)didStopLoad;
- (void)didInitialize;

@end
