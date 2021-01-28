//
//  UIApplication+Additions.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface UIApplication (Additions)

- (UNAuthorizationStatus)notificationsAuthorizationStatus;

- (void)requestNotificationsAuthorization;

- (void)scheduleLocalNotificationWithCategoryIdentifier:(NSString *)categoryIdentifier
												  title:(NSString *)title
												   body:(NSString *)body
												  delay:(NSTimeInterval)delay;
- (void)cancelAllLocalNotifications;

- (void)openSettings;

- (void)setWarningAlertWasDisplayed:(BOOL)displayed;
- (BOOL)isWarningAlertWasDisplayed;
@end
