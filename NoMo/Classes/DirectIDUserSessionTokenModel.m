//
//  DirectIDUserSessionTokenModel.m
//  NoMo
//
//  Created by Costas Harizakis on 9/27/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "DirectIDUserSessionTokenModel.h"
#import "DirectIDAuthenticationModel.h"
#import "DirectIDHTTPSessionManager.h"

#define kNMUserSessionTokenTTL (10 * 60.0) // 10 minutes


@interface DirectIDUserSessionTokenModel () <NMModelDelegate>

@property (nonatomic, strong) DirectIDAuthenticationModel *model;
@property (nonatomic, strong) NSURLSessionDataTask *loadTask;

- (BOOL)performLoad;
- (BOOL)performAuthentication;
- (BOOL)performGetOrUpdateSessionToken;
- (BOOL)cancelLoadIfNeeded;
- (BOOL)cancelAuthenticationIfNeeded;

@end


@implementation DirectIDUserSessionTokenModel

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[self invalidate];
}

#pragma mark - [ Initializer ]

- (instancetype)init
{
	self = [super init];
	
	if (self) {
		_model = nil;
		_loadTask = nil;

		_authenticationEnabled = NO;
		_refreshEnabled = NO;
		_tokenString = nil;
		_reference = nil;
	}
	
	return self;
}

- (instancetype)initForUserWithIdentity:(id<NMIdentity>)userIdentity
{
	self = [self init];
	
	if (self) {
		_userIdentity = userIdentity;
	}
	
	return self;
}

#pragma mark - [ NMModel Methods ]

- (void)invalidate
{
	[super invalidate];
	[self cancelLoad];
	
	_tokenString = nil;
	_reference = nil;
}

- (BOOL)canLoad
{
	if (_loadTask || _model) {
		return NO;
	}
	
	return YES;
}

- (BOOL)load
{
	if (![self canLoad]) {
		return NO;
	}
	if (![self performLoad]) {
		return NO;
	}
	
	[self didStartLoad];

	return YES;
}

- (void)cancelLoad
{
	if ([self cancelAuthenticationIfNeeded] || [self cancelLoadIfNeeded]) {
		[self didCancelLoad];
	}
}

#pragma mark - [ NMModelDelegate Members ]

- (void)modelDidFinishLoad:(id<NMModel>)model
{
	[self cancelAuthenticationIfNeeded];
	[self performGetOrUpdateSessionToken];
}

- (void)modelDidCancelLoad:(id<NMModel>)model
{
	[self cancelAuthenticationIfNeeded];
	[self performGetOrUpdateSessionToken];
}

- (void)model:(id<NMModel>)model didFailLoadWithError:(NSError *)error
{
	[self cancelAuthenticationIfNeeded];
	[self didFailLoadWithError:error];
}

#pragma mark - [ Private Methods ]

- (BOOL)performLoad
{
	DirectIDHTTPSessionManager *manager = [DirectIDHTTPSessionManager defaultManager];
	
	if (!NMTokenIsValid(manager.securityContext.accessToken) && _authenticationEnabled) {
		return [self performAuthentication];
	}

	return [self performGetOrUpdateSessionToken];
}

- (BOOL)performAuthentication
{
	if (_model == nil) {
		_model = [DirectIDAuthenticationModel sharedModel];
		[_model addDelegate:self];
	}
	
	if (_model.isLoading) {
		return YES;
	}
	else if ([_model load]) {
		return YES;
	}
	else {
		[self cancelAuthenticationIfNeeded];
	}

	return [self performGetOrUpdateSessionToken];
}

- (BOOL)performGetOrUpdateSessionToken
{
	NMJSONObjectCompletionHandler completionHandler = ^(NSURLSessionDataTask *task, NSDictionary *properties, NSError *error) {
		if (_loadTask == task) {
			_loadTask = nil;
			
			if (error) {
				[self didFailLoadWithError:error];
			}
			else {
				_tokenString = [properties objectOrNilForKey:@"token"];
				_reference = [properties objectOrNilForKey:@"reference"];
				
				NSLog(@"[UserSessionTokenModel] [Token: %@, Reference: %@]", _tokenString, _reference);
				
				[self setModified:NO];
				[self didFinishLoad];
				[self didChange];
			}
		}
	};
	
	DirectIDHTTPSessionManager *manager = [DirectIDHTTPSessionManager defaultManager];
	
	if (_refreshEnabled) {
		_loadTask = [manager refreshSessionTokenForUserWithIdentity:_userIdentity
												  completionHandler:completionHandler];
	}
	else {
		_loadTask = [manager getSessionTokenForUserWithIdentity:_userIdentity
											  completionHandler:completionHandler];
	}
	
	if (_loadTask == nil) {
		return NO;
	}
	
	return YES;
}

- (BOOL)cancelLoadIfNeeded
{
	if (_loadTask) {
		NSURLSessionDataTask *task = _loadTask;
		_loadTask = nil;
		
		[task cancel];
		
		return YES;
	}
	
	return NO;
}

- (BOOL)cancelAuthenticationIfNeeded
{
	if (_model) {
		[_model removeDelegate:self];
		_model = nil;
		
		return YES;
	}
	
	return NO;
}

@end
