//
//  AFHTTPSessionManager+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/24/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "AFHTTPSessionManager+Additions.h"


//#define _HTTP_DELAY_ 1


@implementation AFHTTPSessionManager (Additions)

#pragma mark - [ Methods (Additions) ]

- (NSURLSessionDataTask *)get:(NSString *)path
				   parameters:(NSDictionary *)parameters
					completed:(NMJSONObjectCompletionHandler)completed
{
	void (^failure)(NSURLSessionDataTask *task, NSError *error) = ^(NSURLSessionDataTask *task, NSError *error) {
		completed(task, nil, error);
	};
	void (^success)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask *task, id json) {
#ifdef _HTTP_200_ON_ERROR_
		if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
			NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
			
			NMLogDebug(@"HTTP status code: %ld", (long)response.statusCode);
			
			if (response.statusCode != 200) {
				NSError *error = [NSError errorWithDomain:@"HTTP" code:response.statusCode userInfo:nil];
				completed(task, nil, error);
				return;
			}
		}
#endif
#ifdef _HTTP_DELAY_
		double delayInSeconds = 2.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
			completed(task, json, nil);
		});
#else
		completed(task, json, nil);
#endif
	};
	
	NSLog(@"[HTTPSessionManager] [GET %@]", path);

	//NSLog(@"[HTTPSessionManager] [GET %@ (HTTP headers follow)]", path);
	//NSLog(@"\n%@", self.requestSerializer.HTTPRequestHeaders.description);
	
    [self.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    
	return [self GET:path parameters:parameters progress:nil success:success failure:failure];
}

- (NSURLSessionDataTask *)get:(NSString *)path
				   parameters:(NSDictionary *)parameters
						 data:(NSData *)data
					completed:(NMJSONObjectCompletionHandler)completed
{
	void (^failure)(NSURLSessionDataTask *task, NSError *error) = ^(NSURLSessionDataTask *task, NSError *error) {
		completed(task, nil, error);
	};
	void (^success)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask *task, id json) {
#ifdef _HTTP_200_ON_ERROR_
		if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
			NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
			
			NMLogDebug(@"HTTP status code: %ld", (long)response.statusCode);
			
			if (response.statusCode != 200) {
				NSError *error = [NSError errorWithDomain:@"HTTP" code:response.statusCode userInfo:nil];
				completed(task, nil, error);
				return;
			}
		}
#endif
	};
	
	NSError *serializationError = nil;
	NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
	request.HTTPBody = data;
	
	if (serializationError) {
		if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
			dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
				failure(nil, serializationError);
			});
#pragma clang diagnostic pop
		}
		
		return nil;
	}
	
	__block NSURLSessionDataTask *task = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
		if (error) {
			if (failure) {
				failure(task, error);
			}
		} else {
			if (success) {
				success(task, responseObject);
			}
		}
	}];
	
	[task resume];
	
	NSLog(@"[HTTPSessionManager] [GET %@]", path);
	
	return task;
}

- (NSURLSessionDataTask *)post:(NSString *)path
					parameters:(NSDictionary *)parameters
					 completed:(NMJSONObjectCompletionHandler)completed
{
	void (^failure)(NSURLSessionDataTask *task, NSError *error) = ^(NSURLSessionDataTask *task, NSError *error) {
		completed(task, nil, error);
	};
	void (^success)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask *task, id json) {
#ifdef _HTTP_DELAY_
		double delayInSeconds = 2.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
			completed(task, json, nil);
		});
#else
		completed(task, json, nil);
#endif
	};

	NSLog(@"[HTTPSessionManager] [POST %@]", path);
    
    self.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
	return [self POST:path parameters:parameters  progress:nil success:success failure:failure];
}

- (NSURLSessionDataTask *)post:(NSString *)path
						  data:(NSData *)data
					 completed:(NMJSONObjectCompletionHandler)completed
{
	void (^failure)(NSURLSessionDataTask *task, NSError *error) = ^(NSURLSessionDataTask *task, NSError *error) {
		completed(task, nil, error);
	};
	void (^success)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask *task, id json) {
#ifdef _HTTP_DELAY_
		double delayInSeconds = 2.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
			completed(task, json, nil);
		});
#else
		completed(task, json, nil);
#endif
	};
	
	NSError *serializationError = nil;
	NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString] parameters:nil error:&serializationError];
	request.HTTPBody = data;
	
	if (serializationError) {
		if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
			dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
				failure(nil, serializationError);
			});
#pragma clang diagnostic pop
		}
		
		return nil;
	}
	
	__block NSURLSessionDataTask *task = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
		if (error) {
			if (failure) {
				failure(task, error);
			}
		} else {
			if (success) {
				success(task, responseObject);
			}
		}
	}];
	
	[task resume];
	
	NSLog(@"[HTTPSessionManager] [POST %@]", path);
	
	return task;
}

- (NSURLSessionDataTask *)post:(NSString *)path
					parameters:(NSDictionary *)parameters
	  completedWithoutResponse:(NMCompletionHandler)completed
{
	void (^failure)(NSURLSessionDataTask *task, NSError *error) = ^(NSURLSessionDataTask *task, NSError *error) {
		completed(task, error);
	};
	void (^success)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask *task, id json) {
		completed(task, nil);
	};
	
	NSLog(@"[HTTPSessionManager] [POST %@]", path);
	
	return [self POST:path parameters:parameters progress:nil success:success failure:failure];
}

- (NSURLSessionDataTask *)put:(NSString *)path
				   parameters:(NSDictionary *)parameters
					completed:(NMCompletionHandler)completed
{
    [self.requestSerializer setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
	void (^failure)(NSURLSessionDataTask *task, NSError *error) = ^(NSURLSessionDataTask *task, NSError *error) {
		completed(task, error);
	};
	void (^success)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask *task, id json) {
#ifdef _HTTP_DELAY_
		double delayInSeconds = 2.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
			completed(task, nil);
		});
#else
		completed(task, nil);
#endif
	};

	NSLog(@"[HTTPSessionManager] [PUT %@]", path);

	return [self PUT:path parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask *)put:(NSString *)path
				   parameters:(NSDictionary *)parameters
						 data:(NSData *)data
					completed:(NMCompletionHandler)completed
{
    [self.requestSerializer setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
	void (^failure)(NSURLSessionDataTask *task, NSError *error) = ^(NSURLSessionDataTask *task, NSError *error) {
		completed(task, error);
	};
	void (^success)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask *task, id json) {
#ifdef _HTTP_DELAY_
		double delayInSeconds = 2.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
			completed(task, nil);
		});
#else
		completed(task, nil);
#endif
	};
	
	NSError *serializationError = nil;
	NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"PUT" URLString:[[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];

	if (serializationError) {
		if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
			dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
				failure(nil, serializationError);
			});
#pragma clang diagnostic pop
		}
		
		return nil;
	}

    [self.requestSerializer setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
	__block NSURLSessionDataTask *task = [self uploadTaskWithRequest:request fromData:data progress:nil completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
		if (error) {
			if (failure) {
				failure(task, error);
			}
		} else {
			if (success) {
				success(task, responseObject);
			}
		}
	}];
	
	[task resume];

	NSLog(@"[HTTPSessionManager] [PUT %@]", path);

	return task;
}

- (NSURLSessionDataTask *)delete:(NSString *)path
					  parameters:(NSDictionary *)parameters
					   completed:(NMCompletionHandler)completed
{
	void (^failure)(NSURLSessionDataTask *task, NSError *error) = ^(NSURLSessionDataTask *task, NSError *error) {
		completed(task, error);
	};
	void (^success)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask *task, id json) {
		completed(task, nil);
	};
	
	NSLog(@"[HTTPSessionManager] [DELETE %@]", path);

	return [self DELETE:path parameters:parameters success:success failure:failure];
}

#pragma mark - [ Methods (Authorization) ]

- (void)setAuthorizationHeaderFieldWithAccessToken:(id<NMToken>)accessToken
{
	[self.requestSerializer clearAuthorizationHeader];
	
	if (accessToken.tokenString) {
		NSString *tokenType = @"Bearer";
		NSString *tokenString = accessToken.tokenString;
		NSString *value = [NSString stringWithFormat:@"%@ %@", tokenType, tokenString];
		
		//NSLog(@"[HTTPSessionManager] [Updating authorization header field (Value: %@)]", value);

		[self.requestSerializer setValue:value forHTTPHeaderField:@"Authorization"];
	}
}

- (void)clearAuthorizationHeader
{
	[self.requestSerializer clearAuthorizationHeader];
}

@end
