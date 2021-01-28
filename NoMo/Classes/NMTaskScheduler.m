//
//  NMTaskScheduler.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMTaskScheduler.h"
#import "NMSession.h"


@interface NMTask : NSObject <NMTask>

@property (nonatomic, weak) NMTaskScheduler *scheduler;
@property (nonatomic, copy, readonly) void (^block)(void);

- (instancetype)initWithBlock:(void (^)(void))block
				 forScheduler:(NMTaskScheduler *)scheduler;

- (void)invoke;
- (void)cancel;

@end


@interface NMPeriodicTask : NMTask

@property (nonatomic, assign,readonly) NSTimeInterval invocationInterval;
@property (nonatomic, copy, readonly) NSDate *dateOfNextInvocation;

- (instancetype)initWithBlock:(void (^)(void))block
						interval:(NSTimeInterval)interval
						   delay:(NSTimeInterval)delay
				 forScheduler:(NMTaskScheduler *)scheduler;

- (void)invoke;

@end


@interface NMTaskScheduler ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *periodicTasks;
@property (nonatomic, strong) NSMutableArray *applicationForegroundTasks;
@property (nonatomic, strong) NSMutableArray *applicationBackgroundTasks;
@property (nonatomic, strong) NSMutableArray *applicationActiveTasks;
@property (nonatomic, strong) NSMutableArray *applicationInactiveTasks;
@property (nonatomic, strong) NSMutableArray *sessionOpenTasks;
@property (nonatomic, strong) NSMutableArray *sessionCloseTasks;
@property (nonatomic, strong) NSMutableArray *sessionVerifyTasks;
@property (nonatomic, strong) NSMutableArray *networkAvailableTasks;
@property (nonatomic, strong) NSMutableArray *networkUnavailableTasks;
@property (nonatomic, assign) BOOL needsProcessPeriodicTasksQueue;
@property (nonatomic, assign) AFNetworkReachabilityStatus reachabilityStatus;

- (void)cancelTask:(NMTask *)task;

- (void)registerObservers;
- (void)unregisterObservers;

@end


@implementation NMTaskScheduler

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[self stop];
}

#pragma mark - [ Initializer ]

- (instancetype)init
{
	self = [super init];
	
	if (self) {
		_periodicTasks = [[NSMutableArray alloc] init];
		_applicationForegroundTasks = [[NSMutableArray alloc] init];
		_applicationBackgroundTasks = [[NSMutableArray alloc] init];
		_applicationActiveTasks = [[NSMutableArray alloc] init];
		_applicationInactiveTasks = [[NSMutableArray alloc] init];
		_sessionOpenTasks = [[NSMutableArray alloc] init];
		_sessionCloseTasks = [[NSMutableArray alloc] init];
		_sessionVerifyTasks = [[NSMutableArray alloc] init];
		_networkAvailableTasks = [[NSMutableArray alloc] init];
		_networkUnavailableTasks = [[NSMutableArray alloc] init];
	}
	
	return self;
}

#pragma mark - [ Methods ]

- (id<NMTask>)addTaskWithBlock:(void (^)(void))block triggers:(NMTaskTriggers)triggers
{
	NMTask *task = [[NMTask alloc] initWithBlock:block forScheduler:self];
	
	if (triggers & NMTaskTriggerApplicationWillEnterForeground) {
		[_applicationForegroundTasks addObject:task];
	}
	if (triggers & NMTaskTriggerApplicationDidEnterBackground) {
		[_applicationBackgroundTasks addObject:task];
	}
	if (triggers & NMTaskTriggerApplicationDidBecomeActive) {
		[_applicationActiveTasks addObject:task];
	}
	if (triggers & NMTaskTriggerApplicationWillResignActive) {
		[_applicationInactiveTasks addObject:task];
	}
	if (triggers & NMTaskTriggerSessionDidOpen) {
		[_sessionOpenTasks addObject:task];
	}
	if (triggers & NMTaskTriggerSessionDidClose) {
		[_sessionCloseTasks addObject:task];
	}
	if (triggers & NMTaskTriggerSessionDidVerify) {
		[_sessionVerifyTasks addObject:task];
	}
	if (triggers & NMTaskTriggerNetworkAvailable) {
		[_networkAvailableTasks addObject:task];
	}
	if (triggers & NMTaskTriggerNetworkUnavailable) {
		[_networkUnavailableTasks addObject:task];
	}
	
	return task;
}

- (id<NMTask>)addPeriodicTaskWithBlock:(void (^)(void))block
						interval:(NSTimeInterval)interval
						   delay:(NSTimeInterval)delay
{
	NMTask *task = [[NMPeriodicTask alloc] initWithBlock:block interval:interval delay:delay forScheduler:self];
	[_periodicTasks addObject:task];
	
	[self setNeedsProcessPeriodicTasksQueue];
	
	return task;
}

- (void)start
{
	if (!_active) {
		[self registerObservers];
		[self startTimer];
		[[AFNetworkReachabilityManager sharedManager] startMonitoring];
	}
}

- (void)stop
{
	if (_active) {
		[[AFNetworkReachabilityManager sharedManager] stopMonitoring];
		[self stopTimer];
		[self unregisterObservers];
	}
}

#pragma mark - [ Handlers ]

- (void)handleApplicationDidFinishLaunchingNotification:(NSNotification *)notification
{
	NSLog(@"[TaskScheduler] [Application did finish launching]");
	
	[self startTimer];
	[self setNeedsProcessPeriodicTasksQueue];
	[self processQueue:_applicationForegroundTasks];
}

- (void)handleApplicationWillEnterForegroundNotification:(NSNotification *)notification
{
	NSLog(@"[TaskScheduler] [Application will enter foreground]");
	
	[self startTimer];
	[self setNeedsProcessPeriodicTasksQueue];
	[self processQueue:_applicationForegroundTasks];
}

- (void)handleApplicationDidEnterBackgroundNotification:(NSNotification *)notification
{
	NSLog(@"[TaskScheduler] [Application did enter background]");
	
	[self stopTimer];
	[self processQueue:_applicationBackgroundTasks];
}

- (void)handleApplicationDidBecomeActiveNotification:(NSNotification *)notification
{
	NSLog(@"[TaskScheduler] [Application did become active]");
	
	[self processQueue:_applicationActiveTasks];
}

- (void)handleApplicationWillResignActiveNotification:(NSNotification *)notification
{
	NSLog(@"[TaskScheduler] [Application will resign active]");
	
	[self processQueue:_applicationInactiveTasks];
}

- (void)handleSessionDidOpenNotification:(NSNotification *)notification
{
	NSLog(@"[TaskScheduler] [Session did open]");
	
	[self processQueue:_sessionOpenTasks];
}

- (void)handleSessionDidCloseNotification:(NSNotification *)notification
{
	NSLog(@"[TaskScheduler] [Session did close]");
	
	[self processQueue:_sessionCloseTasks];
}

- (void)handleSessionDidVerifyNotification:(NSNotification *)notification
{
	NSLog(@"[TaskScheduler] [Session did verify]");
	
	[self processQueue:_sessionVerifyTasks];
}

- (void)handleNetworkReachabilityStatusDidChangeNotification:(NSNotification *)notification
{
	AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
	AFNetworkReachabilityStatus reachabilityStatus = reachabilityManager.networkReachabilityStatus;
	
	if (reachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
		reachabilityStatus = AFNetworkReachabilityStatusReachableViaWWAN;
	}
	
	if (_reachabilityStatus != reachabilityStatus) {
		_reachabilityStatus = reachabilityStatus;
	
		switch (_reachabilityStatus) {
			case AFNetworkReachabilityStatusNotReachable:
				NSLog(@"[TaskScheduler] [Network did become unavailable]");
				[self processQueue:_networkUnavailableTasks];
				break;
			case AFNetworkReachabilityStatusReachableViaWWAN:
			case AFNetworkReachabilityStatusReachableViaWiFi:
				NSLog(@"[TaskScheduler] [Network did become available]");
				[self processQueue:_networkAvailableTasks];
				break;
			default:
				break;
		}
	}
}

#pragma mark - [ Events ]

- (void)handleTimer:(id)sender
{
	[self setNeedsProcessPeriodicTasksQueue];
}

#pragma mark - [ Methods (Private) ]

- (void)startTimer
{
	if (_timer == nil) {
		_timer = [NSTimer scheduledTimerWithTimeInterval:1.0
												  target:self
												selector:@selector(handleTimer:)
												userInfo:nil
												 repeats:YES];
	}
}

- (void)stopTimer
{
	if (_timer) {
		[_timer invalidate];
		_timer = nil;
	}
}

- (void)setNeedsProcessPeriodicTasksQueue
{
	if (_needsProcessPeriodicTasksQueue == NO) {
		_needsProcessPeriodicTasksQueue = YES;
		
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			[self processPeriodicTasksQueue];
		});
	}
}

- (void)processPeriodicTasksQueue
{
	_needsProcessPeriodicTasksQueue = NO;
	[self processQueue:_periodicTasks];
}

- (void)processQueue:(NSArray *)tasks
{
	for (NMTask *task in tasks) {
		[task invoke];
	}
}

- (void)cancelTask:(NMTask *)task
{
	[_periodicTasks removeObject:task];
	[_applicationForegroundTasks removeObject:task];
	[_applicationBackgroundTasks removeObject:task];
	[_applicationActiveTasks removeObject:task];
	[_applicationInactiveTasks removeObject:task];
	[_sessionOpenTasks removeObject:task];
	[_sessionCloseTasks removeObject:task];
	[_sessionVerifyTasks removeObject:task];
	[_networkAvailableTasks removeObject:task];
	[_networkUnavailableTasks removeObject:task];
}

- (void)registerObservers
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	[notificationCenter addObserver:self selector:@selector(handleApplicationDidFinishLaunchingNotification:) name:UIApplicationDidFinishLaunchingNotification object:[UIApplication sharedApplication]];
	[notificationCenter addObserver:self selector:@selector(handleApplicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
	[notificationCenter addObserver:self selector:@selector(handleApplicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
	[notificationCenter addObserver:self selector:@selector(handleApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
	[notificationCenter addObserver:self selector:@selector(handleApplicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
	[notificationCenter addObserver:self selector:@selector(handleSessionDidOpenNotification:) name:kNMSessionDidOpenNotification object:[NMSession sharedSession]];
	[notificationCenter addObserver:self selector:@selector(handleSessionDidCloseNotification:) name:kNMSessionDidCloseNotification object:[NMSession sharedSession]];
	[notificationCenter addObserver:self selector:@selector(handleSessionDidVerifyNotification:) name:kNMSessionDidVerifyNotification object:[NMSession sharedSession]];
	[notificationCenter addObserver:self selector:@selector(handleNetworkReachabilityStatusDidChangeNotification:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

- (void)unregisterObservers
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	[notificationCenter removeObserver:self name:AFNetworkingReachabilityDidChangeNotification object:nil];
	[notificationCenter removeObserver:self name:UIApplicationDidFinishLaunchingNotification object:[UIApplication sharedApplication]];
	[notificationCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
	[notificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
	[notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
	[notificationCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
	[notificationCenter removeObserver:self name:kNMSessionDidOpenNotification object:[NMSession sharedSession]];
	[notificationCenter removeObserver:self name:kNMSessionDidCloseNotification object:[NMSession sharedSession]];
	[notificationCenter removeObserver:self name:kNMSessionDidVerifyNotification object:[NMSession sharedSession]];
}

@end


@implementation NMTaskScheduler (Global)

#pragma mark - [ Constructors (Static) ]

+ (instancetype)defaultScheduler
{
	static NMTaskScheduler *instance;
	static dispatch_once_t once;
	
	dispatch_once(&once, ^(void) {
		instance = [[NMTaskScheduler alloc] init];
	});
	
	return instance;
}

@end


@implementation NMTask

- (instancetype)initWithBlock:(void (^)(void))block forScheduler:(NMTaskScheduler *)scheduler
{
	self = [super init];
	
	if (self) {
		_scheduler = scheduler;
		_block = [block copy];
	}
	
	return self;
}

- (void)invoke
{
	if (_block != nil) {
		_block();
	}
}

- (void)cancel
{
	[_scheduler cancelTask:self];
}

@end


@implementation NMPeriodicTask

- (instancetype)initWithBlock:(void (^)(void))block interval:(NSTimeInterval)interval delay:(NSTimeInterval)delay forScheduler:(NMTaskScheduler *)scheduler
{
	self = [super initWithBlock:block forScheduler:scheduler];
	
	if (self) {
		_invocationInterval = interval;
		_dateOfNextInvocation = [NSDate dateWithTimeIntervalSinceNow:delay];
	}
	
	return self;
}

- (void)invoke
{
	NSDate *now = [NSDate date];
	
	if (![_dateOfNextInvocation isLaterThanDate:now]) {
		NSDate *dateOfNextInvocation = [_dateOfNextInvocation dateByAddingTimeInterval:_invocationInterval];
		_dateOfNextInvocation = [now laterDate:dateOfNextInvocation];
		
		[super invoke];
	}
}

@end

