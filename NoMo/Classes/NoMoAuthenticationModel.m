//
//  NoMoAuthenticationModel.m
//  NoMo
//
//  Created by Costas Harizakis on 10/18/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoAuthenticationModel.h"
#import "NoMoAuthenticationManager.h"
#import "NMAccessTokenItem.h"


@interface NoMoAuthenticationModel ()

@property (nonatomic, strong) NSURLSessionDataTask *loadTask;
@property (nonatomic, strong) NSURLSessionDataTask *saveTask;
@property (nonatomic, strong) NMAccessTokenItem *item;

@end


@implementation NoMoAuthenticationModel

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
	self = [super init];
	
	if (self) {
		_session = session;
		_loadTask = nil;
		_saveTask = nil;
		_item = nil;
	}
	
	return self;
}

#pragma mark - [ Constructors (Static) ]

+ (instancetype)modelWithSession:(id<NMSession>)session
{
	NoMoAuthenticationModel *sharedModel = [NoMoAuthenticationModel sharedModel];
	
	if (session == sharedModel.session) {
		return sharedModel;
	}
	
	return [[NoMoAuthenticationModel alloc] initWithSession:session];
}

#pragma mark - [ Properties ]

- (NSString *)accessTokenString
{
	return _item.accessTokenString;
}

- (NSDate *)lastRefreshDate
{
	return _item.lastRefreshDate;
}

- (NSDate *)expirationDate
{
	return _item.expirationDate;
}

#pragma mark - [ Methods ]

- (BOOL)isExpired
{
	if (_item) {
		return [_item isExpired];
	}
	
	return YES;
}

#pragma mark - [ NMModel Members ]

- (void)invalidate
{
	[super invalidate];
	[self cancelLoad];
	[self cancelSave];
	
	_item = nil;
}

#pragma mark - [ NMModel (Load) ]

- (BOOL)canLoad
{
	if (_loadTask || _saveTask) {
		return NO;
	}
	if (_item.refreshTokenString == nil) {
		return NO;
	}
	
	return YES;
}

- (BOOL)load
{
	if (![self canLoad]) {
		return NO;
	}
	
	NMJSONObjectCompletionHandler completionHandler = ^(NSURLSessionDataTask *task, NSDictionary *properties, NSError *error) {
		if (self.loadTask == task) {
			self.loadTask = nil;
			
			if (error) {
				[self didFailLoadWithError:error];
			}
			else {
				self.item = [[NMAccessTokenItem alloc] initWithProperties:properties];
				
				[self setModified:NO];
				
				[self didFinishLoad];
				[self didChange];
			}
		}
	};
	
	NoMoAuthenticationManager *manager = [NoMoAuthenticationManager defaultManager];
	
	_loadTask = [manager refreshSessionUsingTokenString:_item.refreshTokenString
									  completionHandler:completionHandler];
	
	if (!_loadTask) {
		return NO;
	}
	
	[self didStartLoad];
	
	return YES;
}

- (void)cancelLoad
{
	if (_loadTask) {
		NSURLSessionDataTask *task = _loadTask;
		_loadTask = nil;
		
		[task cancel];

		[self didCancelLoad];
	}
}

#pragma mark - [ NMModel (Save) ]

- (BOOL)canSave
{
	if (_loadTask || _saveTask) {
		return NO;
	}
	
	return YES;
}

- (BOOL)save
{
	if (![self canSave]) {
		return NO;
	}
	
	NMJSONObjectCompletionHandler completionHandler = ^(NSURLSessionDataTask *task, NSDictionary *properties, NSError *error) {
		if (self.saveTask == task) {
			self.saveTask = nil;
			
			if (error) {
				[self didFailSaveWithError:error];
			}
			else {
				self.item = [[NMAccessTokenItem alloc] initWithProperties:properties];
				
				[self setModified:NO];
				[self setLoaded:YES];
				
				[self didFinishSave];
				[self didChange];
			}
		}
	};
	
    if (_session.sessionId == nil) {
        [[NMSession sharedSession] close];
        return NO;
    }
    
	NoMoAuthenticationManager *manager = [NoMoAuthenticationManager defaultManager];
	
    _saveTask = [manager createSessionForUserWithIdentity:_session.userIdentity
                                                sessionId:_session.sessionId
                                        completionHandler:completionHandler];
    
	
	if (!_saveTask) {
		return NO;
	}
	
	[self didStartSave];
	
	return YES;
}

- (void)cancelSave
{
	if (_saveTask) {
		NSURLSessionDataTask *task = _saveTask;
		_saveTask = nil;
		
		[task cancel];

		[self didCancelSave];
	}
}

#pragma mark - [ Static Methods ]

+ (instancetype)sharedModel
{
	static NoMoAuthenticationModel *instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		NMSession *session = [NMSession sharedSession];
		instance = [[NoMoAuthenticationModel alloc] initWithSession:session];
	});
	
	return instance;
}

@end

