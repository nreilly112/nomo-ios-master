//
//  NoMoAuthenticationManager+DirectID.m
//  NoMo
//
//  Created by Costas Harizakis on 10/3/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoAuthenticationManager.h"
#import "NMDevice.h"


@implementation NoMoAuthenticationManager (Authentication)

- (NSURLSessionDataTask *)getAccessTokenWithUserIdentity:(id<NMIdentity>)userIdentity completionHandler: (NMJSONObjectCompletionHandler)completionHandler;
{
    
	NSString *path = [NSString stringWithFormat:@"./connect/token"];
    NSDictionary *parameters = @{ @"grant_type": userIdentity.grantType ?: [NSNull null],
                                  @"scope": userIdentity.scope ?: [NSNull null],
                                  @"client_id": userIdentity.clientId ?: [NSNull null],
                                  @"client_secret": userIdentity.clientSecret ?: [NSNull null] };
    
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

- (NSURLSessionDataTask *)getWidgetSessionTokenForAccessToken:(NSString *)accessToken
                                               completionHandler:(NMJSONObjectCompletionHandler)completionHandler
{
    
    NSString *path = [NSString stringWithFormat:@"./api/DirectID/widget/token"];
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
