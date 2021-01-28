//
//  UIApplication+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "UIApplication+Additions.h"


@implementation UIApplication (Additions)

- (UNAuthorizationStatus)notificationsAuthorizationStatus
{
	__block BOOL completed = NO;
	__block UNAuthorizationStatus authorizationStatus = UNAuthorizationStatusNotDetermined;
	
	UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
	
	[notificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
		authorizationStatus = settings.authorizationStatus;
		completed = YES;
	}];
	
	while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !completed) { };
	
	return authorizationStatus;
}

- (void)requestNotificationsAuthorization
{
	UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
	UNAuthorizationOptions options = UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound;
	
	[notificationCenter requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError *error) {
		if (granted) {
			[self registerForRemoteNotifications];
		}
	}];
}

- (void)scheduleLocalNotificationWithCategoryIdentifier:(NSString *)categoryIdentifier
												  title:(NSString *)title
												   body:(NSString *)body
												  delay:(NSTimeInterval)delay
{
	UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
	UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
	content.categoryIdentifier = categoryIdentifier;
	content.title = title;
	content.body = body;
	content.sound = [UNNotificationSound defaultSound];
	UNNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:MAX(0.01, delay) repeats:NO];
	UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"1" content:content trigger:trigger];
	
	[center addNotificationRequest:request withCompletionHandler:^(NSError *error) {
		if (error) {
			NSLog(@"[Application] [Failed to dispatch notification (Error: %@)]", error.description);
		}
	}];
}

- (void)cancelAllLocalNotifications
{
	UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];

	[notificationCenter removeAllPendingNotificationRequests];
}

- (void)openSettings
{
	NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
	
	[self openURL:settingsURL options:@{ } completionHandler:nil];
}

- (void)setWarningAlertWasDisplayed:(BOOL)displayed {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:displayed forKey:@"isWarningAlertWasDisplayed"];
    [userDefaults synchronize];
}

- (BOOL)isWarningAlertWasDisplayed {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:@"isWarningAlertWasDisplayed"];
}

#pragma mark - [ Private Methods ]

@end
