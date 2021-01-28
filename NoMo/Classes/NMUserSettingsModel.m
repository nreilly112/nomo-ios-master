//
//  NMUserSettingsModel.m
//  NoMo
//
//  Created by Costas Harizakis on 9/26/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMUserSettingsModel.h"
#import "NMUserSettingsItem.h"


@interface NMUserSettingsModel ()

@property (nonatomic, copy) NMUserSettingsItem *item;
@property (nonatomic, strong) NSURLSessionDataTask *loadTask;
@property (nonatomic, strong) NSURLSessionDataTask *saveTask;
@property (nonatomic, copy) NSString *stateKey;

- (instancetype)initWithSession:(id<NMSession>)session;

- (void)updateStateKey;
- (void)restoreState;
- (void)saveState;

- (NSString *)temporaryPathWithIdentifier:(NSString *)identifier;

@end


@implementation NMUserSettingsModel

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[self invalidate];
}

#pragma mark - [ Initializers ]

- (instancetype)init
{
	return [self initWithSession:nil];
}

- (instancetype)initWithSession:(id<NMSession>)session
{
	self = [super initWithSession:session];
	
	if (self) {
		_item = [[NMUserSettingsItem alloc] init];
		_loadTask = nil;
		_saveTask = nil;
		
		[self updateStateKey];
		[self restoreState];
	}
	
	return self;
}

#pragma mark - [ Properties ]

- (NSString *)preferredCurrencyCode
{
	return _item.preferredCurrencyCode;
}

- (void)setPreferredCurrencyCode:(NSString *)value
{
	if (![_item.preferredCurrencyCode isEqualToString:value]) {
		[self willChangeValueForKey:@"preferredCurrencyCode"];
		_item.preferredCurrencyCode = value;
		[self setModified:YES];
		[self didChangeValueForKey:@"preferredCurrencyCode"];
		[self didChange];
	}
}

- (CGFloat)incrementNotificationThreshold
{
	return _item.incrementNotificationThreshold;
}

- (void)setIncrementNotificationThreshold:(CGFloat)value
{
	if (_item.incrementNotificationThreshold != value) {
		[self willChangeValueForKey:@"incrementNotificationThreshold"];
		_item.incrementNotificationThreshold = value;
		[self setModified:YES];
		[self didChangeValueForKey:@"incrementNotificationThreshold"];
		[self didChange];
	}
}

- (CGFloat)decrementNotificationThreshold
{
	return _item.decrementNotificationThreshold;
}

- (void)setDecrementNotificationThreshold:(CGFloat)value
{
	if (_item.decrementNotificationThreshold != value) {
		[self willChangeValueForKey:@"decrementNotificationThreshold"];
		_item.decrementNotificationThreshold = value;
		[self setModified:YES];
		[self didChangeValueForKey:@"decrementNotificationThreshold"];
		[self didChange];
	}
}

- (NMApplicationPersona)applicationPersona
{
	return _item.applicationPersona;
}

- (void)setApplicationPersona:(NMApplicationPersona)value
{
	if (_item.applicationPersona != value) {
		[self willChangeValueForKey:@"applicationPersona"];
		_item.applicationPersona = value;
		[self setModified:YES];
		[self didChangeValueForKey:@"applicationPersona"];
		[self didChange];
	}
}

- (BOOL)notificationsEnabled
{
	return _item.notificationsEnabled;
}

- (BOOL)includeOverdraft
{
    return _item.includeOverdraft;
}

- (void)setNotificationsEnabled:(BOOL)value
{
	if (_item.notificationsEnabled != value) {
		[self willChangeValueForKey:@"notificationsEnabled"];
		_item.notificationsEnabled = value;
		[self setModified:YES];
		[self didChangeValueForKey:@"notificationsEnabled"];
		[self didChange];
	}
}

- (void)setIncludeOverdraft:(BOOL)value
{
    if (_item.includeOverdraft != value) {
        [self willChangeValueForKey:@"includeOverdraft"];
        _item.includeOverdraft = value;
        [self setModified:YES];
        [self didChangeValueForKey:@"includeOverdraft"];
        [self didChange];
    }
}

#pragma mark - [ NoMoModel Protected Methods ]

- (void)sessionDidOpen
{
	[self updateStateKey];
	[self restoreState];
}

#pragma mark - [ NMModel Methods ]

- (void)invalidate
{
	[super invalidate];
	
	_item = [[NMUserSettingsItem alloc] init];
	
	[self saveState];
}

#pragma mark - [ NoMoLoadModel Members ]

- (NSURLSessionDataTask *)loadTaskWithSessionManager:(NoMoHTTPSessionManager *)manager
{
	if (!self.session.isOpen) {
		return nil;
	}

	NMJSONObjectCompletionHandler completionHandler = ^(NSURLSessionDataTask *task, NSDictionary *properties, NSError *error) {
		if (self.loadTask == task) {
			self.loadTask = nil;
			
			if (error) {
				[self didFailLoadWithError:error];
			}
			else {
				self.item = [[NMUserSettingsItem alloc] initWithProperties:properties];
				[self saveState];
				
				[self setModified:NO];
				[self didFinishLoad];
				[self didChange];
			}
		}
	};
	
	_loadTask = [manager getSettingsForUserWithIdentity:self.session.userIdentity
									  completionHandler:completionHandler];
	
	if (_loadTask) {
		[self didStartLoad];
	}
	
	return _loadTask;
}

- (void)didCancelLoadTask:(NSURLSessionDataTask *)task
{
	if (_loadTask == task) {
		_loadTask = nil;
		[self didCancelLoad];
	}
}

#pragma mark - [ NoMoSaveModel Members ]

- (NSURLSessionDataTask *)saveTaskWithSessionManager:(NoMoHTTPSessionManager *)manager
{
	if (!self.session.isOpen) {
		return nil;
	}
	
	NMCompletionHandler completionHandler = ^(NSURLSessionDataTask *task, NSError *error) {
		if (self.saveTask == task) {
			self.saveTask = nil;
			
			if (error) {
				[self didFailSaveWithError:error];
			}
			else {
				[self saveState];
				
				[self setModified:NO];
				[self didFinishSave];
			}
		}
	};
	
	_saveTask = [manager updateSettings:_item
					forUserWithIdentity:self.session.userIdentity
					  completionHandler:completionHandler];
	
	if (_saveTask) {
		[self didStartSave];
	}
	
	return _saveTask;
}

- (void)didCancelSaveTask:(NSURLSessionDataTask *)task
{
	if (_saveTask == task) {
		_saveTask = nil;
		[self didCancelSave];
	}
}

#pragma mark - [ Private methods ]

- (void)restoreState
{
	if (_stateKey) {
		NSString *path = [self temporaryPathWithIdentifier:_stateKey];
		NSDictionary *properties = [NSDictionary dictionaryWithContentsOfFile:path];
		
		if (properties.count == 0) {
			properties = nil;
		}
		
		NSLog(@"[UserSettingsModel] [Restoring state (Path: \"%@\")]", path);
		
		_item = [properties itemOfKind:[NMUserSettingsItem class]];
		
		if (_item) {
			[self setLoaded:YES];
			[self didChange];
		}
	}
}

- (void)saveState
{
	if (_stateKey) {
		NSString *path = [self temporaryPathWithIdentifier:_stateKey];
		
		if (_item) {
			NSLog(@"[UserSettingsModel] [Saving state (Path: \"%@\")]", path);
			[_item.properties writeToFile:path atomically:YES];
		}
		else {
			NSLog(@"[UserSettingsModel] [Clearing state (Path: \"%@\")]", path);
			[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		}
	}
}

- (void)updateStateKey
{
	if (self.session.isOpen) {
		//_stateKey = self.session.reference;
	}
}

- (NSString *)temporaryPathWithIdentifier:(NSString *)identifier
{
	NSString *file = [NSString stringWithFormat:@"user_settings_%@.plist", identifier ?: @"default" ];
	NSString *path = [file stringByPrependingDefaultCacheDirectory];
	
	return path;
}

#pragma mark - [ Static Methods ]

+ (instancetype)sharedModel
{
	static NMUserSettingsModel *instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		NMSession *session = [NMSession sharedSession];
		instance = [[NMUserSettingsModel alloc] initWithSession:session];
		instance.authenticationEnabled = YES;
	});
	
	return instance;
}

@end
