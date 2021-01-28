//
//  NMUserNotificationsModel.m
//  NoMo
//
//  Created by Costas Harizakis on 9/24/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMUserNotificationsModel.h"


@interface NMUserNotificationsModel ()

@property (nonatomic, copy) NSString *deviceTokenString;
@property (nonatomic, strong) NSURLSessionDataTask *loadTask;
@property (nonatomic, strong) NSURLSessionDataTask *saveTask;

- (instancetype)initWithSession:(id<NMSession>)session;

@end


@implementation NMUserNotificationsModel

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
		_saveTask = nil;
	}
	
	return self;
}

#pragma mark - [ Properties ]

- (void)setDeviceToken:(NSData *)deviceToken
{
	if (![_deviceToken isEqualToData:deviceToken]) {
		[self willChangeValueForKey:@"deviceToken"];
		_deviceToken = [deviceToken copy];
		[self setModified:YES];
		[self didChangeValueForKey:@"deviceToken"];
		[self didChange];
	}
}

#pragma mark - [ Properties (Private) ]

- (NSString *)deviceTokenString
{
	//return [_deviceToken base64EncodedStringWithOptions:0];
	return [_deviceToken hexString];
}

- (void)setDeviceTokenString:(NSString *)deviceTokenString
{
	//_deviceToken = [[NSData alloc] initWithBase64EncodedString:deviceTokenString options:0];
	_deviceToken = [NSData dataWithHexString:deviceTokenString];
}

#pragma mark - [ NMModel ]

- (void)invalidate
{
	[super invalidate];
	
	_deviceToken = nil;
}

#pragma mark - [ NMModel (Save) ]

- (BOOL)canSave
{
	if (_deviceToken == nil) {
		return NO;
	}
	
	return [super canSave];
}

#pragma mark - [ NoMoLoadModel Members ]

- (void)didCancelLoadTask:(NSURLSessionDataTask *)task
{
	if (_loadTask == task) {
		_loadTask = nil;
		[self didCancelLoad];
	}
}

- (NSURLSessionDataTask *)loadTaskWithSessionManager:(NoMoHTTPSessionManager *)manager {
    return nil;
}

#pragma mark - [ NoMoSaveModel Members ]

- (NSURLSessionDataTask *)saveTaskWithSessionManager:(NoMoHTTPSessionManager *)manager
{
	NMJSONObjectCompletionHandler completionHandler = ^(NSURLSessionDataTask *task, NSDictionary *properties, NSError *error) {
		if (self.saveTask == task) {
			self.saveTask = nil;
			
			if (error) {
				[self didFailSaveWithError:error];
			}
			else {
                [self registerUserForNotification:manager registrationId:[NSString stringWithFormat:@"%@", properties]];
			}
		}
	};
	
	_saveTask = [manager registerDeviceToken:self.deviceTokenString
						 completionHandler:completionHandler];
	
	if (_saveTask) {
		[self didStartSave];
	}
	
	return _saveTask;
}

- (NSURLSessionDataTask *)registerUserForNotification:(NoMoHTTPSessionManager *)manager registrationId:(NSString *)registrationId
{
    NMCompletionHandler completionHandler = ^(NSURLSessionDataTask *task, NSError *error) {
        if (self.saveTask == task) {
            self.saveTask = nil;
            
            if (error) {
                NSLog(@"[RemoteNotifications] [User registration failed (Error: %@)]", error.description);
                [self didFailSaveWithError:error];
            }
            else {
                NSLog(@"[RemoteNotifications] [User registration completed (DeviceToken: %@)]", self.deviceTokenString);
                [self setModified:NO];
                [self setLoaded:YES];
                [self didFinishSave];
            }
        }
    };
    
    _saveTask = [manager registerUserWithRegistrationId:registrationId
                                            deviceToken:self.deviceTokenString
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

#pragma mark - [ Static Methods ]

+ (instancetype)sharedModel
{
	static NMUserNotificationsModel *instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		NMSession *session = [NMSession sharedSession];
		instance = [[NMUserNotificationsModel alloc] initWithSession:session];
		instance.authenticationEnabled = YES;
	});
	
	return instance;
}

@end

