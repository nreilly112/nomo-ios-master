//
//  NoMoExtensionDelegate.m
//  Watch Extension
//
//  Created by Costas Harizakis on 21/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoExtensionDelegate.h"
#import "NMExtensionModel.h"


@interface NoMoExtensionDelegate () <NMModelDelegate>

@property (nonatomic, strong) NMExtensionModel *model;

@end


@implementation NoMoExtensionDelegate

#pragma mark - [ WKExtensionDelegate ]

- (void)applicationDidFinishLaunching
{
	_model = [NMExtensionModel sharedModel];
	[_model addDelegate:self];
}

- (void)applicationDidBecomeActive
{

}

- (void)applicationWillResignActive
{

}

- (void)handleBackgroundTasks:(NSSet<WKRefreshBackgroundTask*>*)backgroundTasks
{
    for (WKRefreshBackgroundTask *task in backgroundTasks) {
        if ([task isKindOfClass:[WKApplicationRefreshBackgroundTask class]]) {
            WKApplicationRefreshBackgroundTask *backgroundTask = (WKApplicationRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompleted];
        }
		else if ([task isKindOfClass:[WKSnapshotRefreshBackgroundTask class]]) {
            WKSnapshotRefreshBackgroundTask *snapshotTask = (WKSnapshotRefreshBackgroundTask*)task;
            [snapshotTask setTaskCompletedWithDefaultStateRestored:YES estimatedSnapshotExpiration:[NSDate distantFuture] userInfo:nil];
        }
		else if ([task isKindOfClass:[WKWatchConnectivityRefreshBackgroundTask class]]) {
            WKWatchConnectivityRefreshBackgroundTask *backgroundTask = (WKWatchConnectivityRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompleted];
        }
		else if ([task isKindOfClass:[WKURLSessionRefreshBackgroundTask class]]) {
            WKURLSessionRefreshBackgroundTask *backgroundTask = (WKURLSessionRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompleted];
        }
		else {
            [task setTaskCompleted];
        }
    }
}

#pragma mark - [ NMModel Mmebers ]

- (void)modelDidChange:(id<NMModel>)model
{
	NSLog(@"[ExtensionModel] [WatchApp endpoint did change (Date: %@)]", _model.date.description);
}

@end
