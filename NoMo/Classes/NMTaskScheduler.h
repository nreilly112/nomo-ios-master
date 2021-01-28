//
//  NMTaskScheduler.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


typedef NS_ENUM(NSInteger, NMTaskTriggers) {
	NMTaskTriggerApplicationWillEnterForeground = 1 << 1,
	NMTaskTriggerApplicationDidEnterBackground = 1 << 2,
	NMTaskTriggerApplicationDidBecomeActive = 1 << 3,
	NMTaskTriggerApplicationWillResignActive = 1 << 4,
	NMTaskTriggerSessionDidOpen = 1 << 5,
	NMTaskTriggerSessionDidClose = 1 << 6,
	NMTaskTriggerSessionDidVerify = 1 << 7,
	NMTaskTriggerNetworkAvailable = 1 << 8,
	NMTaskTriggerNetworkUnavailable = 1 << 9
};


@protocol NMTask <NSObject>

- (void)cancel;

@end


@interface NMTaskScheduler : NSObject

@property (nonatomic, assign, readonly, getter = isActive) BOOL active;

- (id<NMTask>)addTaskWithBlock:(void (^)(void))block
					  triggers:(NMTaskTriggers)triggers;

- (id<NMTask>)addPeriodicTaskWithBlock:(void (^)(void))block
							  interval:(NSTimeInterval)interval
								 delay:(NSTimeInterval)delay;

- (void)start;
- (void)stop;

@end


@interface NMTaskScheduler (Global)

+ (instancetype)defaultScheduler;

@end



