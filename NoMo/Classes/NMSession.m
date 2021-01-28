//
//  NMSession.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMSession.h"
#import "NMSessionStateModel.h"
#import "NMTaskScheduler.h"
#import "NoMoHTTPSessionManager.h"


#define kSessionKey @"com.miicard.session"

#define kSessionUserIdentityGrantType @"com.miicard.session.userIdentify.GrantType"
#define kSessionUserIdentityScope @"com.miicard.session.userIdentify.Scope"
#define kSessionUserIdentityClientId @"com.miicard.session.userIdentify.clientId"
#define kSessionUserIdentityClientSecret @"com.miicard.session.userIdentify.clientSecret"
#define kSessionUserIdentitySessionId @"com.miicard.session.userIdentify.SessionId"

//#define kSessionUserIdentityNameKey @"com.miicard.session.userIdentify.name"
//#define kSessionUserIdentityDomainKey @"com.miicard.session.userIdentify.domain"
//#define kSessionReferenceKey @"com.miicard.session.reference"
#define kSessionNumberOfLoginAttemptsKey @"com.miicard.session.numberOfAttempts"
#define kSessionNumberOfFailedLoginAttemptsKey @"com.miicard.session.numberOfFailedLoginAttempts"
#define kSessionVerificationStateKey @"com.miicard.session.verificationState"


NSString * const kNMSessionDidOpenNotification = @"com.miicard.session.didOpen";
NSString * const kNMSessionDidCloseNotification = @"com.miicard.session.didClose";
NSString * const kNMSessionDidVerifyNotification = @"com.miicard.session.didVerify";
NSString * const kNMSessionDidFailVerifyNotification = @"com.miicard.session.didFailVerify";
NSString * const kNMSessionDidChangeNotification = @"com.miicard.session.didChange";

NSString * const kNMSessionParameterNumberOfLoginAttempts = @"numberOfLoginAttempts";
NSString * const kNMSessionParameterNumberOfFailedLoginAttempts = @"numberOfFailedLoginAttempts";
NSString * const kNMSessionParameterVerificationState = @"verificationState";


@interface NMSession () <NMModelDelegate>

@property (nonatomic, strong) id<NMIdentity> userIdentity;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, assign) NSInteger numberOfLoginAttempts;
@property (nonatomic, assign) NSInteger numberOfFailedLoginAttempts;
@property (nonatomic, assign) NMSessionVerificationState verificationState;
@property (nonatomic, strong) NMSessionStateModel *model;
@property (nonatomic, strong) NSArray *tasks;

- (void)updateVerificationState;

@end


@implementation NMSession

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[self close];
}

#pragma mark - [ Initializers ]

- (instancetype)init
{
	self = [super init];
	
	if (self) {
		_model = nil;
		_tasks = nil;
	}

	return self;
}

#pragma mark - [ Properties ]

- (BOOL)isOpen
{
	return (_model != nil);
}

- (BOOL)isVerified
{
	return (_verificationState == NMSessionVerificationStateApproved);
}

#pragma mark - [ Methods ]

- (void)openForUserWithIdentity:(id<NMIdentity>)userIdentity
                      sessionId:(NSString*)sessionId
					 parameters:(NSDictionary *)parameters
{
	[self close];
	
	_userIdentity = userIdentity;
    _sessionId = sessionId;
	_numberOfLoginAttempts = [parameters integerValueOrZeroForKey:kNMSessionParameterNumberOfLoginAttempts];
	_numberOfFailedLoginAttempts = [parameters integerValueOrZeroForKey:kNMSessionParameterNumberOfFailedLoginAttempts];
	_verificationState = [parameters integerValueOrZeroForKey:kNMSessionParameterVerificationState];
	
	_model = [[NMSessionStateModel alloc] initWithSession:self];
	_model.authenticationEnabled = YES;
	[_model addDelegate:self];
	
	//[self registerTasks];

	[self saveState];

	[self sessionDidOpen];
	[self sessionDidChange];

	if (_verificationState == NMSessionVerificationStateApproved) {
		[self sessionDidVerify];
		[self sessionDidChange];
	}
	
	// NOTE: Refresh the verification status just in case a previously
	// logged on user has been invalidated.
	
	//[self verifyIfNeeded];
}

- (void)openExisting
{
	[self restoreState];
}

- (void)close
{
	if (_model) {
        /* request to logout
		NoMoHTTPSessionManager *manager = [NoMoHTTPSessionManager defaultManager];
		id<NMIdentity> userIdentity = _userIdentity;
		
		[manager invalidateSessionForUserWithIdentity:_userIdentity
									completionHandler:^(NSURLSessionDataTask *task, NSError *error) {
										if (error) {
											NSLog(@"[Session] [Session did failed to invalidate (UserIdentity: %@ (@%@), GrantType: %@]", userIdentity.clientId, userIdentity.clientSecret, userIdentity.grantType);
										}
										else {
											NSLog(@"[Session] [Session did become invalid (UserIdentity: %@ (@%@), GrantType: %@]", userIdentity.clientId, userIdentity.clientSecret, userIdentity.grantType);
										}
									}];
        
         */
		
		[self unregisterTasks];
        
		[_model removeDelegate:self];
		[_model invalidate];
		_model = nil;
		
		_userIdentity = nil;
		_numberOfLoginAttempts = 0;
		_numberOfFailedLoginAttempts = 0;
		_verificationState = NMSessionVerificationStateUnknown;

        NoMoContext *context = [NoMoContext sharedContext];
        context.currencyCode = nil;

        NSUserDefaults *recognizedCurrency = [NSUserDefaults standardUserDefaults];
        [recognizedCurrency removeObjectForKey:@"recognizedCurrency"];
        [recognizedCurrency synchronize];
        
        [[UIApplication sharedApplication] setWarningAlertWasDisplayed:NO];
        
		[self saveState];

		[self sessionDidClose];
		[self sessionDidChange];
	}
}

- (void)setNeedsVerification
{
	[_model invalidate];
}

- (void)verifyIfNeeded
{
	if (!_model.isLoaded && !_model.isLoading) {
		[_model load];
	}
}

#pragma mark - [ Events ]

- (void)sessionDidOpen
{
	//NSLog(@"[Session] [Session did open (UserIdentity: %@ (@%@), Reference: %@]", _userIdentity.name, _userIdentity.domain, _reference);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNMSessionDidOpenNotification object:self userInfo:nil];
}

- (void)sessionDidClose
{
	NSLog(@"[Session] [Session did close]");
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNMSessionDidCloseNotification object:self userInfo:nil];
}

- (void)sessionDidVerify
{
	NSLog(@"[Session] [Session did verify]");
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNMSessionDidVerifyNotification object:self userInfo:nil];
}

- (void)sessionDidFailVerifyWithError:(NSError *)error
{
	NSLog(@"[Session] [Session did fail verify with error: %@]", error.description);
	
	NSDictionary *userInfo = @{ @"error": error };
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNMSessionDidFailVerifyNotification object:self userInfo:userInfo];
}

- (void)sessionDidChange
{
	NSLog(@"[Session] [Session did change]");
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNMSessionDidChangeNotification object:self userInfo:nil];
}

#pragma mark - [ NMModelDelegate Methods ]

- (void)modelDidFinishLoad:(id<NMModel>)model
{
	//[self updateVerificationState];
}

- (void)model:(id<NMModel>)model didFailLoadWithError:(NSError *)error
{
	// TODO: Just log the error.
	
	NSLog(@"[Session] [Session state update operation failed (Error: %@).", error.description);
}

#pragma mark - [ Private Methods ]

- (void)updateVerificationState
{
	if (!_model.isLoaded) {
		return;
	}
	
	if (_model.verificationState == NMSessionVerificationStateUnknown) {
		[self setNeedsVerification];
		return;
	}

	if (_model.verificationState != NMSessionVerificationStateApproved) {
		// NOTE: Verify that before handling an error, it actually refers to the user's
		// last login attempt.
		
		if ((0 < _numberOfLoginAttempts) && ([_model numberOfVerifiedLoginAttempts] < _numberOfLoginAttempts)) {
			[self setNeedsVerification];
			return;
		}
	}

	if (_verificationState != _model.verificationState) {
		_verificationState = _model.verificationState;
		
		switch (_verificationState) {
			case NMSessionVerificationStateApproved:
				[self sessionDidVerify];
				[self sessionDidChange];
				break;
			case NMSessionVerificationStateRejected:
				[self sessionDidFailVerifyWithError:_model.verificationError];
				[self close];
				break;
			case NMSessionVerificationStateSuspended:
				[self sessionDidFailVerifyWithError:_model.verificationError];
				[self close];
			default:
				break;
		}

		[self saveState];
	}
}

- (void)registerTasks
{
	void (^verifySession)(void) = ^(void) {
		[self verifyIfNeeded];
	};
	
	NMTaskScheduler *scheduler = [NMTaskScheduler defaultScheduler];
	
	_tasks = @[[scheduler addPeriodicTaskWithBlock:verifySession interval:10.0 delay:0.0],
			   [scheduler addTaskWithBlock:verifySession triggers:NMTaskTriggerApplicationDidBecomeActive]];
}

- (void)unregisterTasks
{
	for (id<NMTask> task in _tasks) {
		[task cancel];
	}
	
	_tasks = nil;
}

- (void)saveState
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	
	if ([self isOpen]) {
		[settings setBool:YES forKey:kSessionKey];
		[settings setObject:_userIdentity.grantType forKey:kSessionUserIdentityGrantType];
        [settings setObject:_userIdentity.clientSecret forKey:kSessionUserIdentityClientSecret];
        [settings setObject:_userIdentity.clientId forKey:kSessionUserIdentityClientId];
        [settings setObject:_userIdentity.scope forKey:kSessionUserIdentityScope];
        [settings setObject:_sessionId forKey:kSessionUserIdentitySessionId];
		[settings setInteger:_numberOfLoginAttempts forKey:kSessionNumberOfLoginAttemptsKey];
		[settings setInteger:_numberOfFailedLoginAttempts forKey:kSessionNumberOfFailedLoginAttemptsKey];
		[settings setInteger:_verificationState forKey:kSessionVerificationStateKey];
	}
	else {
		[settings removeObjectForKey:kSessionKey];
        [settings removeObjectForKey:kSessionUserIdentityGrantType];
        [settings removeObjectForKey:kSessionUserIdentityClientSecret];
        [settings removeObjectForKey:kSessionUserIdentityClientId];
        [settings removeObjectForKey:kSessionUserIdentityScope];
        [settings removeObjectForKey:kSessionUserIdentitySessionId];
		[settings removeObjectForKey:kSessionNumberOfLoginAttemptsKey];
		[settings removeObjectForKey:kSessionNumberOfFailedLoginAttemptsKey];
		[settings removeObjectForKey:kSessionVerificationStateKey];
	}
	
	[settings synchronize];
}

- (void)restoreState
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];

	if ([settings objectForKey:kSessionKey]) {
		NSString *grantType = [settings objectForKey:kSessionUserIdentityGrantType];
		NSString *clientId = [settings objectForKey:kSessionUserIdentityClientId];
		NSString *clientSecret = [settings objectForKey:kSessionUserIdentityClientSecret];
        NSString *scope = [settings objectForKey:kSessionUserIdentityScope];
        NSString *sessionId = [settings objectForKey:kSessionUserIdentitySessionId];
		NSInteger numberOfLoginAttempts = [settings integerForKey:kSessionNumberOfLoginAttemptsKey];
		NSInteger numberOfFailedLoginAttempts = [settings integerForKey:kSessionNumberOfFailedLoginAttemptsKey];
		NMSessionVerificationState verificationState = [settings integerForKey:kSessionVerificationStateKey];
		NSDictionary *parameters = @{ kNMSessionParameterNumberOfLoginAttempts: @(numberOfLoginAttempts),
									  kNMSessionParameterNumberOfFailedLoginAttempts: @(numberOfFailedLoginAttempts),
									  kNMSessionParameterVerificationState: @(verificationState) };
		
		id<NMIdentity> identity = [NMIdentity identityWithGrantType:grantType clientId:clientId clientSecret:clientSecret scope:scope];
		
        [self openForUserWithIdentity:identity sessionId:sessionId parameters:parameters];
	}
}

@end


@implementation NMSession (Global)

#pragma mark - [ Constructors (Static) ]

+ (instancetype)sharedSession
{
	static NMSession *instance;
	static dispatch_once_t once;
	
	dispatch_once(&once, ^(void) {
		instance = [[NMSession alloc] init];
	});
	
	return instance;
}

@end
