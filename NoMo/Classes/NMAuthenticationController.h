//
//  NMAuthenticationController.h
//  NoMo
//
//  Created by Costas Harizakis on 10/18/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@class NMAuthenticationController;

@protocol NMAuthenticationControllerDelegate <NSObject>

@optional

- (void)authenticationControllerDidComplete:(NMAuthenticationController *)viewController;
- (void)authenticationControllerDidCancel:(NMAuthenticationController *)viewController;
- (void)authenticationController:(NMAuthenticationController *)viewController didFailWithError:(NSError *)error;

@end


@interface NMAuthenticationController : UIViewController

@property (nonatomic, weak) id<NMAuthenticationControllerDelegate> delegate;

- (void)didComplete;
- (void)didCancel;
- (void)didFailWithError:(NSError *)error;

@end
