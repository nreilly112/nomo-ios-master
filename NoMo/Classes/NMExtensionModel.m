//
//  NMExtensionModel.m
//  NoMo
//
//  Created by Costas Harizakis on 21/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import <WatchConnectivity/WatchConnectivity.h>

#import "NMExtensionModel.h"
#import "NMExtensionItem.h"


@interface NMExtensionModel () <WCSessionDelegate>

@property (nonatomic, strong) WCSession *session;
@property (nonatomic, strong) NMExtensionItem *item;

@end


@implementation NMExtensionModel

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	_session.delegate = nil;
}

#pragma mark - [ Initializer ]

- (instancetype)init
{
	self = [super init];
	
	if (self) {
		if ([WCSession isSupported]) {
			_session = [WCSession defaultSession];
			_session.delegate = self;
		}

		NSDictionary *data = [_session.receivedApplicationContext objectOrNilForKey:@"data"];
		[self updateModelWithData:data];
		
		[_session activateSession];
	}
	
	return self;
}

#pragma mark - [ Properties ]

- (NSDate *)date
{
	return _item.date;
}

- (void)setDate:(NSDate *)date
{
	if (_item.date != date) {
		[self willChangeValueForKey:@"date"];
		_item.date = date;
		[self setModified:YES];
		[self didChangeValueForKey:@"date"];
		[self didChange];
	}
}

- (NSString *)heading
{
	return _item.heading;
}

- (void)setHeading:(NSString *)heading
{
	if (_item.heading != heading) {
		[self willChangeValueForKey:@"heading"];
		_item.heading = heading;
		[self setModified:YES];
		[self didChangeValueForKey:@"heading"];
		[self didChange];
	}
}

- (NSString *)comment
{
	return _item.comment;
}

- (void)setComment:(NSString *)comment
{
	if (_item.comment != comment) {
		[self willChangeValueForKey:@"comment"];
		_item.comment = comment;
		[self setModified:YES];
		[self didChangeValueForKey:@"comment"];
		[self didChange];
	}
}

- (NMAmount *)fundsBalance
{
	return _item.fundsBalance;
}

- (void)setFundsBalance:(NMAmount *)fundsBalance
{
	if (_item.fundsBalance != fundsBalance) {
		[self willChangeValueForKey:@"fundsBalance"];
		_item.fundsBalance = fundsBalance;
		[self setModified:YES];
		[self didChangeValueForKey:@"fundsBalance"];
		[self didChange];
	}
}

- (NMAmount *)fundsHistoricAverage
{
	return _item.fundsHistoricAverage;
}

- (void)setFundsHistoricAverage:(NMAmount *)fundsHistoricAverage
{
	if (_item.fundsHistoricAverage != fundsHistoricAverage) {
		[self willChangeValueForKey:@"fundsHistoricAverage"];
		_item.fundsHistoricAverage = fundsHistoricAverage;
		[self setModified:YES];
		[self didChangeValueForKey:@"fundsHistoricAverage"];
		[self didChange];
	}
}

- (UIImage *)fundsGraph
{
	return _item.fundsGraph;
}

- (void)setFundsGraph:(UIImage *)fundsGraph
{
	if (_item.fundsGraph != fundsGraph) {
		[self willChangeValueForKey:@"fundsGraph"];
		_item.fundsGraph = fundsGraph;
		[self setModified:YES];
		[self didChangeValueForKey:@"fundsGraph"];
		[self didChange];
	}
}

#pragma mark - [ Events ]

- (void)invalidate
{
	[super invalidate];
	
	[self updateModelWithData:nil];
	[self synchronizeWithData:nil error:nil];
}

- (BOOL)canSave
{
	return (_session != nil);
}

- (BOOL)save
{
	if (![self canSave]) {
		return NO;
	}
	
	[self setLoaded:YES];
	[self didStartSave];
	[self performBlockOnMainThread:^(void) {
		NSError *error = nil;
		
		if (![self synchronizeWithData:self.item.properties error:&error]) {
			[self didFailSaveWithError:error];
		}
		else {
			[self didFinishSave];
		}
	}];
	
	return YES;
}

#pragma mark - [ NSKeyValueObserving ]

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
	return NO;
}

#pragma mark - [ WCSessionDelegate Members ]

- (void)sessionReachabilityDidChange:(WCSession *)session
{
	NSLog(@"[ExtensionModel] [Reachability changed (Reachable: %@)]", _session.isReachable ? @"YES" : @"NO");
	
	if (_session.isReachable && self.isLoaded && self.isModified) {
		if ([self synchronizeWithData:_item.properties error:nil]) {
			[self setModified:NO];
		}
	}
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message
{
	NSLog(@"[ExtensionModel] [Message received]");
	
	if (self.isLoaded && self.isModified) {
		if ([self synchronizeWithData:_item.properties error:nil]) {
			[self setModified:NO];
		}
	}
}

- (void)sessionDidBecomeInactive:(WCSession *)session
{
	NSLog(@"[ExtensionModel] [Session did become inactive]");
}

- (void)sessionDidDeactivate:(WCSession *)session
{
	NSLog(@"[ExtensionModel] [Session did deactivate]");
}

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error
{
	if (activationState == WCSessionActivationStateActivated) {
		NSLog(@"[ExtensionModel] [Session activated]");
		
		[_session sendMessage:@{ } replyHandler:nil errorHandler:nil];
		
		if (self.isLoaded && self.isModified) {
			if ([self synchronizeWithData:_item.properties error:nil]) {
				[self setModified:NO];
			}
		}
	}
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext
{
	NSLog(@"[ExtensionModel] [Update received]");
	
	NSDictionary *data = [applicationContext objectOrNilForKey:@"data"];
	[self updateModelWithData:data];
	[self didChange];
}

#pragma mark - [ Private Methods ]

- (void)updateModelWithData:(NSDictionary *)data
{
	if (data) {
		_item = [[NMExtensionItem alloc] initWithProperties:data];
		[self setModified:NO];
		[self setLoaded:YES];
	}
	else {
		_item = [[NMExtensionItem alloc] init];
		[self setModified:NO];
		[self setLoaded:NO];
	}
}

- (BOOL)synchronizeWithData:(NSDictionary *)data error:(NSError **)errorRef
{
	if (![self isPaired]) {
		return NO;
	}
	
	NSError *error = nil;
	NSMutableDictionary *context = [NSMutableDictionary dictionary];
 
	if (data) {
		[context setObject:[data dictionaryByRemovingNilValues] forKey:@"data"];
	}
	
	NSLog(@"[ExtensionModel] [Synchronizing]");

	if (![_session updateApplicationContext:context error:&error]) {
		NSLog(@"[ExtensionModel] [Failed to synchronize context (Error: %@)]", error.description);
		if (errorRef) {
			*errorRef = error;
		}
		return NO;
	}
	
	return YES;
}

- (BOOL)isPaired
{
#if TARGET_OS_IOS
	return _session.isPaired;
#else	
	return YES;
#endif
}

#pragma mark - [ Constructors (Static) ]

+ (instancetype)sharedModel
{
	static NMExtensionModel *instance;
	static dispatch_once_t once;
	
	dispatch_once(&once, ^(void) {
		instance = [[NMExtensionModel alloc] init];
	});
	
	return instance;
}

@end
