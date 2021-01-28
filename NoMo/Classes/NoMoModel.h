//
//  NoMoModel.h
//  NoMo
//
//  Created by Costas Harizakis on 02/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMModel.h"
#import "NMSession.h"
#import "NoMoHTTPSessionManager.h"


@protocol NoMoLoadModel <NSObject>

- (NSURLSessionDataTask *)loadTaskWithSessionManager:(NoMoHTTPSessionManager *)manager;
- (void)didCancelLoadTask:(NSURLSessionDataTask *)task;

@end


@protocol NoMoSaveModel <NSObject>

- (NSURLSessionDataTask *)saveTaskWithSessionManager:(NoMoHTTPSessionManager *)manager;
- (void)didCancelSaveTask:(NSURLSessionDataTask *)task;

@end


@interface NoMoModel : NMModel

@property (nonatomic, strong, readonly) id<NMSession> session;

@property (nonatomic, assign) BOOL authenticationEnabled;
@property (nonatomic, assign, readonly, getter = isAuthenticating) BOOL authenticating;

- (instancetype)initWithSession:(id<NMSession>)session;

- (void)sessionDidOpen;
- (void)sessionDidVerify;
- (void)sessionDidClose;

@end
