//
//  NMSessionStateModel.m
//  NoMo
//
//  Created by Costas Harizakis on 10/5/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMSessionStateModel.h"


@interface NMSessionStateModel () <NMModelDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *loadTask;

@end


@implementation NMSessionStateModel

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
		_loadTask = nil;
		
		_numberOfVerifiedLoginAttempts = 0;
		_verificationState = NMSessionVerificationStateUnknown;
		_verificationError = nil;
		_lastRefreshDate = nil;
	}
	
	return self;
}

#pragma mark - [ NMModel Methods]

- (void)invalidate
{
	[super invalidate];
	
	_numberOfVerifiedLoginAttempts = 0;
	_verificationState = NMSessionVerificationStateUnknown;
	_verificationError = nil;
	_lastRefreshDate = nil;
}

#pragma mark - [ NoMoLoadModel Members ]

- (NSURLSessionDataTask *)loadTaskWithSessionManager:(NoMoHTTPSessionManager *)manager
{
    return nil;
}

- (void)didCancelLoadTask:(NSURLSessionDataTask *)task
{
	if (_loadTask == task) {
		_loadTask = nil;
		[self didCancelLoad];
	}
}

@end
