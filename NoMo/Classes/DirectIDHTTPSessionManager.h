//
//  DirectIDHTTPSessionManager.h
//  NoMo
//
//  Created by Costas Harizakis on 9/27/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMHTTPSessionManager.h"
#import "NMIdentity.h"


@interface DirectIDHTTPSessionManager : NMHTTPSessionManager

+ (instancetype)defaultManager;

@end


@interface DirectIDHTTPSessionManager (Session)

// GET /{domain}/user/session/{userID}
- (NSURLSessionDataTask *)getSessionTokenForUserWithIdentity:(id<NMIdentity>)userIdentity
										   completionHandler:(NMJSONObjectCompletionHandler)completionHandler;

// GET /{domain}/user/session/{userID}/reconnect
- (NSURLSessionDataTask *)refreshSessionTokenForUserWithIdentity:(id<NMIdentity>)userIdentity
											   completionHandler:(NMJSONObjectCompletionHandler)completionHandler;

@end


@interface DirectIDHTTPSessionManager (Individuals)

// GET /individuals
- (NSURLSessionDataTask *)getIndividualsWithCompletionHandler:(NMJSONArrayCompletionHandler)completionHandler;

// GET /individual/{reference}
- (NSURLSessionDataTask *)getDetailsForIndividualWithReference:(NSString *)reference
											 completionHandler:(NMJSONObjectCompletionHandler)completionHandler;

// GET /individual/{reference}/isongoing
- (NSURLSessionDataTask *)verifyAccessForIndividualWithReference:(NSString *)reference
											   completionHandler:(NMJSONObjectCompletionHandler)completionHandler;

@end