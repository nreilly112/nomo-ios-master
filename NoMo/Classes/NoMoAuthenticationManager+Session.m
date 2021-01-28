//
//  NoMoAuthenticationManager+Session.m
//  NoMo
//
//  Created by Costas Harizakis on 10/3/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoAuthenticationManager.h"
#import "NMDevice.h"


@implementation NoMoAuthenticationManager (Session)

- (NSURLSessionDataTask *)createSessionForUserWithIdentity:(id<NMIdentity>)userIdentity
                                                 sessionId:(NSString*)sessionId
										 completionHandler:(NMJSONObjectCompletionHandler)completionHandler
{
	NSString *path = [NSString stringWithFormat:@"./connect/token"];
	NSDictionary *parameters = @{ @"grant_type": @"password",
                                  @"client_id": @"ios",
                                  @"client_secret": @"AXvWeNcGLmyszyCgBzMhk",
                                  @"scope": @"nomo offline_access",
                                  @"device_id": [NMDevice uniqueIdentifier],
                                  @"username": sessionId ?: [NSNull null],
                                  @"password": @"WHATEVER_BUT_NOT_EMPTY" };
    NSLog(@"[createSessionForUserWithIdentity] parameters: %@", parameters);
	return [self post:path parameters:parameters completed:^(NSURLSessionDataTask *task, id json, NSError *error) {
		if (error == nil) {
            NSDictionary *properties = json;
			completionHandler(task, properties, nil);
		}
		else {
			completionHandler(task, nil, error);
		}
	}];
}

- (NSURLSessionDataTask *)refreshSessionUsingTokenString:(NSString *)refreshToken
									   completionHandler:(NMJSONObjectCompletionHandler)completionHandler
{
    NSString *path = [NSString stringWithFormat:@"./connect/token"];
    NSDictionary *parameters = @{ @"grant_type": @"refresh_token",
                                  @"client_id": [NoMoSettings clientId],
                                  @"client_secret": [NoMoSettings clientSecret],
                                  @"refresh_token": refreshToken };
	
	return [self post:path parameters:parameters completed:^(NSURLSessionDataTask *task, id json, NSError *error) {
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
