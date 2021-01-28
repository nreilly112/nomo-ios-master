//
//  NoMoAppDelegate.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoAppDelegate.h"
#import "NoMoContext.h"
#import "NoMoSecurityContext.h"
#import "NoMoAuthenticationModel.h"

#import "NMSession.h"
#import "NMDevice.h"
#import "NMUserSettingsModel.h"
#import "NMUserNotificationsModel.h"
#import "NMUserFinancialStatementModel.h"
#import "NMSummaryMessagesModel.h"
#import "NMImageListModel.h"
#import "NMTaskScheduler.h"
#import "NMImageCache.h"


#define kUpdatedVersion24 @"com.miicard.update.settings.version.2.4"
#define kUpdatedLatestVersion kUpdatedVersion24

@interface NoMoAppDelegate () <NMModelDelegate, UNUserNotificationCenterDelegate>

@property (nonatomic, strong) NMSession *session;
@property (nonatomic, strong) NMTaskScheduler *scheduler;
@property (nonatomic, strong) NMUserSettingsModel *settings;
@property (nonatomic, strong) NMUserNotificationsModel *notifications;
@property (nonatomic, strong) NMUserFinancialStatementModel *financialStatement;

- (void)sessionDidOpen;
- (void)sessionDidVerify;
- (void)sessionDidClose;

- (void)configureAppearance;
- (void)configureImageCache;
- (void)synchronizeContext;
- (void)requestNotificationsAuthorization;
- (void)handleRemoteNotification:(NSDictionary *)userInfo;

@end


@implementation NoMoAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSLog(@"Starting on device: <%@>", [NMDevice uniqueIdentifier]);
    
	[self configureAppearance];
	[self configureImageCache];
	
	_session = [NMSession sharedSession];
	
	_scheduler = [NMTaskScheduler defaultScheduler];
	[_scheduler start];
	
	_settings = [NMUserSettingsModel sharedModel];
	[_settings addDelegate:self];

	_notifications = [NMUserNotificationsModel sharedModel];
 	[_notifications addDelegate:self];
	
	_financialStatement = [NMUserFinancialStatementModel sharedModel];
	[_financialStatement addDelegate:self];
	
	__weak NoMoAppDelegate *weakSelf = self;
	[_scheduler addTaskWithBlock:^(void) { [weakSelf sessionDidOpen]; } triggers:NMTaskTriggerSessionDidOpen];
	[_scheduler addTaskWithBlock:^(void) { [weakSelf sessionDidClose]; } triggers:NMTaskTriggerSessionDidClose];
	[_scheduler addTaskWithBlock:^(void) { [weakSelf sessionDidVerify]; } triggers:NMTaskTriggerSessionDidVerify];

	UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
	notificationCenter.delegate = self;
	
    [self resetStateIfUITesting];
    
    if ([self shouldLogoutAfterUpdate]) {
        [_session close];
        return YES;
    }
    
	[_session openExisting];

	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	NSLog(@"[Application] [Will resign active]");
	
	[application setApplicationIconBadgeNumber:0];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	NSLog(@"[Application] [Did enter background]");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	NSLog(@"[Application] [Will enter foreground]");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	NSLog(@"[Application] [Did become active]");

	UNAuthorizationStatus authorizationStatus = application.notificationsAuthorizationStatus;
	
	if (authorizationStatus == UNAuthorizationStatusAuthorized) {
		if (_notifications.deviceToken == nil) {
			[application registerForRemoteNotifications];
		}
	}
    
    if (_session.isOpen) {
        [_financialStatement load];
    }
	
	[[NMSummaryMessagesModel summaryHeadingsModel] load];
	[[NMSummaryMessagesModel summaryCommentsModel] load];
	[[NMImageListModel welcomeImagesModel] load];

	[application setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	NSLog(@"[Application] [Will terminate]");
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    NSString *externalURL = url.absoluteString;
    if ([externalURL hasPrefix:[NoMoSettings widgetRedirectURL]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.nomo.urlscheme" object:url.absoluteString];
        return YES;
    }
    return NO;
}

#pragma mark - [ Remote Notifications ]

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	NSLog(@"[Application] [Remote notification registration succeeded] [%@]", deviceToken);
	
	[_notifications invalidate];
	
	if (deviceToken != nil) {
		_notifications.deviceToken = deviceToken;
		
		if (_session.isOpen) {
			[_notifications save];
		}
	}
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	NSLog(@"[Application] [Remote notification registration failed (reason: %@)]", error.description);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	NSLog(@"[Application] [Remote notification received (UserInfo: %@)]", userInfo.description ?: @"(null)");
	
	[self handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	NSLog(@"[Application] [Remote notification received (UserInfo: %@)]", userInfo.description ?: @"(null)");
	
	[self handleRemoteNotification:userInfo];

	completionHandler(UIBackgroundFetchResultNoData);
}

#pragma mark - [ Session ]

- (void)sessionDidOpen
{
	NSLog(@"[Application] [Session did open]");
    
    if (![[UIApplication sharedApplication] isWarningAlertWasDisplayed]) {
        [self displayWarningAlert];
        [[UIApplication sharedApplication] setWarningAlertWasDisplayed:YES];
    } else {
        // to avoid covering
        [[UIApplication sharedApplication] requestNotificationsAuthorization];
    }
    
	if (_notifications.deviceToken) {
		[_notifications save];
	}

	[self synchronizeContext];
	[_settings load];
}

- (void)sessionDidClose
{
	NSLog(@"[Application] [Session did close]");
	
	[[UIApplication sharedApplication] unregisterForRemoteNotifications];

	[_settings invalidate];
	[_notifications invalidate];
	[_financialStatement invalidate];
	
	[[NoMoAuthenticationModel sharedModel] invalidate];
	[[NoMoSecurityContext defaultContext] setAccessToken:nil];
}

- (void)sessionDidVerify
{
	NSLog(@"[Application] [Session did verify]");
	
	[_financialStatement load];
}

#pragma mark - [ NMModelDelegate ]

- (void)modelDidChange:(id<NMModel>)model
{
	if (model == _settings) {
		[self synchronizeContext];
	}
}

- (void)modelDidFinishSave:(id<NMModel>)model
{
	if (model == _settings) {
		[self synchronizeContext];
		
		if (_settings.notificationsEnabled) {
			[self requestNotificationsAuthorization];
		}
	}
}

#pragma mark - [ UNUserNotificationCenterDelegate ]

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
	UNNotificationPresentationOptions options = UNNotificationPresentationOptionNone;
 
	if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
		options =  UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound;
	}
	else if ([notification.request.trigger isKindOfClass:[UNTimeIntervalNotificationTrigger class]]) {
		options =  UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound;
	}

	completionHandler(options);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
	completionHandler();
}

#pragma mark - [ Methods (Private) ]

- (void)configureAppearance
{
	// Nothing to be done.
}

- (void)configureImageCache
{
	AFImageDownloader *imageDownloader = [AFImageDownloader defaultInstance];
	NMImageCache *imageCache = [[NMImageCache alloc] init];
	
	imageDownloader.imageCache = imageCache;
}

- (void)synchronizeContext
{
	NoMoContext *context = [NoMoContext sharedContext];
	
	if (_settings.isLoaded) {
		context.currencyCode = _settings.preferredCurrencyCode;
		context.applicationPersona = _settings.applicationPersona;
	}
}

- (void)requestNotificationsAuthorization
{
	UIApplication *application = [UIApplication sharedApplication];

	if (application.notificationsAuthorizationStatus == UNAuthorizationStatusNotDetermined) {
		[application requestNotificationsAuthorization];
	}
	else if (application.notificationsAuthorizationStatus == UNAuthorizationStatusDenied) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning"
																	   message:@"Notifications are not currently enabled."
																preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleCancel handler:nil];
		UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[[UIApplication sharedApplication] openSettings];
		}];
		[alert addAction:defaultAction];
		[alert addAction:settingsAction];
		
		[_window.rootViewController presentViewController:alert animated:YES completion:nil];
	}
}

- (void)handleRemoteNotification:(NSDictionary *)userInfo
{
	NSLog(@"[Application] [Push notification received (dump follows)]");
	NSLog(@"\n%@", userInfo.description);
}

- (void)displayWarningAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Important message"
                                                                   message:@"NoMo compares how much you normally have in your current account today vs. what you normally have. If the difference is close to zero, it means you're doing well and that you are finances are consistent."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"I understand"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         // display notification request
                                                         [[UIApplication sharedApplication] requestNotificationsAuthorization];
                                                     }];
    
    [alert addAction:okAction];
    [_window.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (BOOL)shouldLogoutAfterUpdate {
    NSUserDefaults *updateSettings = [NSUserDefaults standardUserDefaults];
    BOOL updatedVersion  = [updateSettings boolForKey:kUpdatedLatestVersion];
    if (updatedVersion) {
        return NO;
    }
    [updateSettings setBool:YES forKey:kUpdatedLatestVersion];
    [updateSettings synchronize];
    
    return YES;
}

- (void)resetStateIfUITesting {
    if ([NSProcessInfo.processInfo.arguments containsObject:@"UI-Testing"]) {
        [NSUserDefaults.standardUserDefaults removePersistentDomainForName:NSBundle.mainBundle.bundleIdentifier];
    }
}
@end
