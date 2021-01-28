//
//  DirectIDHTTPSessionManager+UserSession.m
//  NoMo
//
//  Created by Costas Harizakis on 9/27/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "DirectIDHTTPSessionManager.h"

#define kDefaultUserId @"defaultuser"
#define kDefaultDomain @"undefineddomain"


@implementation DirectIDHTTPSessionManager (Session)

#pragma mark - [ Methods ]

- (NSURLSessionDataTask *)getSessionTokenForUserWithIdentity:(id<NMIdentity>)userIdentity
										   completionHandler:(NMJSONObjectCompletionHandler)completionHandler
{
	NSString *path = [NSString stringWithFormat:@"./%@/user/session/%@",
					  userIdentity.domain ?: kDefaultDomain,
					  userIdentity.name ?: kDefaultUserId];
	NSDictionary *parameters = @{ };
	
	return [self get:path parameters:parameters completed:^(NSURLSessionDataTask *task, id json, NSError *error) {
		if (error == nil) {
			NSDictionary *properties = json;
			completionHandler(task, properties, nil);
		}
		else {
			completionHandler(task, nil, error);
		}
	}];
}

- (NSURLSessionDataTask *)refreshSessionTokenForUserWithIdentity:(id<NMIdentity>)userIdentity
											   completionHandler:(NMJSONObjectCompletionHandler)completionHandler
{
	NSString *path = [NSString stringWithFormat:@".%@/user/session/%@/reconnect",
					  userIdentity.domain ?: kDefaultDomain,
					  userIdentity.name ?: kDefaultUserId];
	NSDictionary *parameters = @{ };
	
	return [self get:path parameters:parameters completed:^(NSURLSessionDataTask *task, id json, NSError *error) {
		if (error == nil) {
			NSDictionary *properties = json;
			completionHandler(task, properties, nil);
		}
		else {
			completionHandler(task, nil, error);
		}
	}];
}

@end
