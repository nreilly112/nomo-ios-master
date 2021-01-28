//
//  NoMoModel.m
//  NoMo
//
//  Created by Costas Harizakis on 02/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoModel.h"
#import "NoMoAuthenticationModel.h"
#import "NoMoHTTPSessionManager.h"


typedef BOOL(^NMURLSessionDataTaskOperation)(void);


@interface NoMoModel () <NMModelDelegate>

@property (nonatomic, strong) NoMoHTTPSessionManager *manager;
@property (nonatomic, strong) NMSecurityContext *securityContext;
@property (nonatomic, strong) NoMoAuthenticationModel *model;
@property (nonatomic, strong) NSURLSessionDataTask *loadTask;
@property (nonatomic, strong) NSURLSessionDataTask *saveTask;
@property (nonatomic, strong) NMURLSessionDataTaskOperation operation;

- (BOOL)initiateTaskWithOperation:(NMURLSessionDataTaskOperation)operation;
- (BOOL)performAuthentication;
- (void)cancelAuthentication;
- (void)authenticationDidComplete;
- (void)authenticationDidFailWithError:(NSError *)error;
- (BOOL)performTask;
- (BOOL)initiateLoadTask;
- (BOOL)initiateSaveTask;

- (void)updateSecurityContext;

- (void)registerObservers;
- (void)unregisterObservers;

- (void)handleSessionDidOpenNotification:(NSNotification *)notification;
- (void)handleSessionDidVerifyNotification:(NSNotification *)notification;
- (void)handleSessionDidCloseNotification:(NSNotification *)notification;

@end


@implementation NoMoModel

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[self unregisterObservers];
	[self invalidate];
}

#pragma mark - [ Initializers ]

- (instancetype)init
{
	return [self initWithSession:nil];
}

- (instancetype)initWithSession:(id<NMSession>)session
{
	self = [super init];
	
	if (self) {
		_session = session;
		_manager = [NoMoHTTPSessionManager defaultManager];
		_securityContext = _manager.securityContext;
		_model = nil;
		_loadTask = nil;
		_saveTask = nil;
		_operation = nil;
		
		[self registerObservers];		
	}
	
	return self;
}

#pragma mark - [ Properties ]

- (BOOL)isAuthenticating
{
	return (_model.isLoading || _model.isSaving);
}

#pragma mark - [ Events ]

- (void)sessionDidOpen
{
	// Nothing to be done.
}

- (void)sessionDidVerify
{
	// Nothing to be done.
}

- (void)sessionDidClose
{
	// Nothing to be done.
}

#pragma mark - [ NMModel Methods ]

- (void)invalidate
{
	[self cancelAuthentication];
	[self cancelLoad];
	[self cancelSave];

	[self setModified:NO];
	[self setLoaded:NO];
}

#pragma mark - [ NMModel (Load) ]

- (BOOL)canLoad
{
	if (![self conformsToProtocol:@protocol(NoMoLoadModel)]) {
		return NO;
	}
	if (self.isAuthenticating) {
		return NO;
	}
	if (self.isLoading || self.isSaving) {
		return NO;
	}
	
	return YES;
}

- (BOOL)load
{
	NMURLSessionDataTaskOperation operation = ^BOOL(void) {
		return [self initiateLoadTask];
	};

	if (![self canLoad]) {
		return NO;
	}
	if (![self initiateTaskWithOperation:operation]) {
		return NO;
	}
	
	[self didStartLoad];
	
	return YES;
}

- (void)cancelLoad
{
	if (self.isLoading) {
		if (self.isAuthenticating) {
			[self cancelAuthentication];
		}

		if (_loadTask) {
			NSURLSessionDataTask *task = _loadTask;
			_loadTask = nil;
            
            @try {
                [task cancel];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception.reason);
            }
			[self didCancelLoadTask:task];
		}
	
		[self didCancelLoad];
	}
}

#pragma mark - [ NMModel (Load) ]

- (BOOL)canSave
{
	if (![self conformsToProtocol:@protocol(NoMoSaveModel)]) {
		return NO;
	}
	if (self.isAuthenticating) {
		return NO;
	}
	if (self.isLoading || self.isSaving) {
		return NO;
	}
	
	return YES;
}

- (BOOL)save
{
	NMURLSessionDataTaskOperation operation = ^BOOL(void) {
		return [self initiateSaveTask];
	};
	
	if (![self canSave]) {
		return NO;
	}
	if (![self initiateTaskWithOperation:operation]) {
		return NO;
	}
	
	[self didStartSave];
	
	return YES;
}

- (void)cancelSave
{
	if (self.isSaving) {
		if (self.isAuthenticating) {
			[self cancelAuthentication];
		}
		
		if (_saveTask) {
			NSURLSessionDataTask *task = _saveTask;
			_saveTask = nil;
			
			[task cancel];
			[self didCancelSaveTask:task];
		}

		[self didCancelSave];
	}
}

#pragma mark - [ NMModelDelegate Members ]

- (void)modelDidFinishLoad:(id<NMModel>)model
{
	[self authenticationDidComplete];
}

- (void)modelDidCancelLoad:(id<NMModel>)model
{
	[self authenticationDidComplete];
}

- (void)model:(id<NMModel>)model didFailLoadWithError:(NSError *)error
{
	[self authenticationDidFailWithError:error];
}

- (void)modelDidFinishSave:(id<NMModel>)model
{
	[self authenticationDidComplete];
}

- (void)modelDidCancelSave:(id<NMModel>)model
{
	[self authenticationDidComplete];
}

- (void)model:(id<NMModel>)model didFailSaveWithError:(NSError *)error
{
	[self authenticationDidFailWithError:error];
}

#pragma mark - [ Private Methods ]

- (BOOL)initiateTaskWithOperation:(NMURLSessionDataTaskOperation)operation
{
	_operation = operation;
	
	if (_authenticationEnabled && !NMTokenIsValid(_securityContext.accessToken)) {
		return [self performAuthentication];
	}
	
	return [self performTask];
}

- (BOOL)performAuthentication
{
	if (_model == nil) {
		_model = [NoMoAuthenticationModel modelWithSession:_session];
		[_model addDelegate:self];
	}
	
	if (_model.isSaving || _model.isLoading) {
		return YES;
	}
	else if ([_model canLoad] && [_model load]) {
		return YES;
	}
	else if ([_model canSave] && [_model save]) {
		return YES;
	}
	else {
		[self cancelAuthentication];
	}
	
	return [self performTask];
}

- (void)cancelAuthentication
{
	if (_model) {
		[_model removeDelegate:self];
		_model = nil;
	}
}

- (void)authenticationDidComplete
{
	[self updateSecurityContext];
	[self cancelAuthentication];
	[self performTask];
}

- (void)authenticationDidFailWithError:(NSError *)error
{
	[self cancelAuthentication];

	if (self.isLoading) {
		[self didFailLoadWithError:error];
	}
	else if (self.isSaving) {
		[self didFailSaveWithError:error];
	}
}

- (BOOL)performTask
{
	return _operation();
}

- (BOOL)initiateLoadTask
{
	_loadTask = [self loadTaskWithSessionManager:_manager];
	
	if (_loadTask == nil) {
		return NO;
	}

	return YES;
}

- (BOOL)initiateSaveTask
{
	_saveTask = [self saveTaskWithSessionManager:_manager];
	
	if (_saveTask == nil) {
		return NO;
	}
	
	return YES;
}

#pragma mark - [ Protected Methods ]

- (NSURLSessionDataTask *)loadTaskWithSessionManager:(NoMoHTTPSessionManager *)manager
{
	return nil;
}

- (NSURLSessionDataTask *)saveTaskWithSessionManager:(NoMoHTTPSessionManager *)manager
{
	return nil;
}

- (void)didCancelLoadTask:(NSURLSessionDataTask *)task
{
	// Nothing to be done.
}

- (void)didCancelSaveTask:(NSURLSessionDataTask *)task
{
	// Nothing to be done.
}

- (void)updateSecurityContext
{
	if (_model.isLoaded) {
		NSLog(@"[SecurityContext] [Updating (AccessToken: %@, ExpirationDate: %@)]",
			  _model.accessTokenString,
			  _model.expirationDate.description);
		
		NMToken *accessToken = [NMToken tokenWithTokenString:_model.accessTokenString
											  expirationDate:_model.expirationDate];
		_securityContext.accessToken = accessToken;
	}
}

#pragma mark - [ Private Methods ]

- (void)registerObservers
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

	if (_session) {
		[notificationCenter addObserver:self selector:@selector(handleSessionDidOpenNotification:) name:kNMSessionDidOpenNotification object:_session];
		[notificationCenter addObserver:self selector:@selector(handleSessionDidVerifyNotification:) name:kNMSessionDidVerifyNotification object:_session];
		[notificationCenter addObserver:self selector:@selector(handleSessionDidCloseNotification:) name:kNMSessionDidCloseNotification object:_session];
	}
}

- (void)unregisterObservers
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	if (_session) {
		[notificationCenter removeObserver:self name:kNMSessionDidOpenNotification object:_session];
		[notificationCenter removeObserver:self name:kNMSessionDidVerifyNotification object:_session];
		[notificationCenter removeObserver:self name:kNMSessionDidCloseNotification object:_session];
	}
}

#pragma mark - [ Private Handlers ]

- (void)handleSessionDidOpenNotification:(NSNotification *)notification
{
	[self sessionDidOpen];
}

- (void)handleSessionDidVerifyNotification:(NSNotification *)notification
{
	[self sessionDidVerify];
}

- (void)handleSessionDidCloseNotification:(NSNotification *)notification
{
	[self sessionDidClose];
}

@end
