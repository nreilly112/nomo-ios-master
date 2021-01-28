//
//  AFHTTPSessionManager+Additions.h
//  NoMo
//
//  Created by Costas Harizakis on 9/24/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMToken.h"


typedef void (^NMJSONObjectCompletionHandler)(NSURLSessionDataTask *task, NSDictionary *json, NSError *error);
typedef void (^NMJSONArrayCompletionHandler)(NSURLSessionDataTask *task, NSArray *json, NSError *error);
typedef void (^NMCompletionHandler)(NSURLSessionDataTask *task, NSError *error);


@interface AFHTTPSessionManager (Additions)

- (NSURLSessionDataTask *)get:(NSString *)path
				   parameters:(NSDictionary *)parameters
					completed:(NMJSONObjectCompletionHandler)completed;

- (NSURLSessionDataTask *)get:(NSString *)path
				   parameters:(NSDictionary *)parameters
						 data:(NSData *)data
					completed:(NMJSONObjectCompletionHandler)completed;

- (NSURLSessionDataTask *)post:(NSString *)path
					parameters:(NSDictionary *)parameters
					 completed:(NMJSONObjectCompletionHandler)completed;

- (NSURLSessionDataTask *)post:(NSString *)path
						  data:(NSData *)data
					 completed:(NMJSONObjectCompletionHandler)completed;

- (NSURLSessionDataTask *)post:(NSString *)path
					parameters:(NSDictionary *)parameters
	  completedWithoutResponse:(NMCompletionHandler)completed;

- (NSURLSessionDataTask *)put:(NSString *)path
				   parameters:(NSDictionary *)parameters
					completed:(NMCompletionHandler)completed;

- (NSURLSessionDataTask *)put:(NSString *)path
				   parameters:(NSDictionary *)parameters
						 data:(NSData *)data
					completed:(NMCompletionHandler)completed;

- (NSURLSessionDataTask *)delete:(NSString *)path
					  parameters:(NSDictionary *)parameters
					   completed:(NMCompletionHandler)completed;

- (void)setAuthorizationHeaderFieldWithAccessToken:(id<NMToken>)accessToken;
- (void)clearAuthorizationHeader;

@end



