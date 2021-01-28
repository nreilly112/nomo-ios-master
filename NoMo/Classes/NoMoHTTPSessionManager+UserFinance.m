//
//  NoMoHTTPSessionManager+UserFinance.m
//  NoMo
//
//  Created by Costas Harizakis on 10/20/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoHTTPSessionManager.h"


@implementation NoMoHTTPSessionManager (UserFinance)

- (NSURLSessionDataTask *)getFinancialStatementForUserWithIdentity:(id<NMIdentity>)userIdentity
												 completionHandler:(NMJSONObjectCompletionHandler)completionHandler
{
	NSString *path = [NSString stringWithFormat:@"./CashFlow"];
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
