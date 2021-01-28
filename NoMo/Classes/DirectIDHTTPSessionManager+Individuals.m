//
//  DirectIDHTTPSessionManager+Individuals.m
//  NoMo
//
//  Created by Costas Harizakis on 9/29/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "DirectIDHTTPSessionManager.h"

#define kDefaultReference @"defaultreference"


@implementation DirectIDHTTPSessionManager (Individuals)

#pragma mark - [ Methods ]

- (NSURLSessionDataTask *)getIndividualsWithCompletionHandler:(NMJSONArrayCompletionHandler)completionHandler
{
	NSString *path = [NSString stringWithFormat:@"./individuals"];
	NSDictionary *parameters = @{ };
	
	return [self get:path parameters:parameters completed:^(NSURLSessionDataTask *task, id json, NSError *error) {
		if (error == nil) {
			NSArray *arrayOfProperties = [json valueForKey:@"Individuals"];
			completionHandler(task, arrayOfProperties, nil);
		}
		else {
			completionHandler(task, nil, error);
		}
	}];
	
}

- (NSURLSessionDataTask *)getDetailsForIndividualWithReference:(NSString *)reference
											 completionHandler:(NMJSONObjectCompletionHandler)completionHandler
{
	NSString *path = [NSString stringWithFormat:@"./individual/%@", reference ?: kDefaultReference];
	NSDictionary *parameters = @{ };
	
	return [self get:path parameters:parameters completed:^(NSURLSessionDataTask *task, id json, NSError *error) {
		if (error == nil) {
			NSDictionary *properties = [json valueForKey:@"Individual"];
			completionHandler(task, properties, nil);
		}
		else {
			completionHandler(task, nil, error);
		}
	}];
}

- (NSURLSessionDataTask *)verifyAccessForIndividualWithReference:(NSString *)reference
											   completionHandler:(NMJSONObjectCompletionHandler)completionHandler
{
	NSString *path = [NSString stringWithFormat:@"./individual/%@", reference ?: kDefaultReference];
	NSDictionary *parameters = @{ };
	
	return [self get:path parameters:parameters completed:^(NSURLSessionDataTask *task, id json, NSError *error) {
		if (error == nil) {
			BOOL value = [json boolValue];
			NSDictionary *properties = @{ @"Reference": reference,
										  @"IsOnGoing": [NSNumber numberWithBool:value] };
			completionHandler(task, properties, nil);
		}
		else {
			completionHandler(task, nil, error);
		}
	}];
}

@end
