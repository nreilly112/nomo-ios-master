//
//  DirectIDAuthenticationManager.h
//  NoMo
//
//  Created by Costas Harizakis on 13/12/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface DirectIDAuthenticationManager : AFHTTPSessionManager

+ (instancetype)defaultManager;

@end


@interface DirectIDAuthenticationManager (Authentication)

- (NSURLSessionDataTask *)getAccessTokenWithCompletionHandler:(NMJSONObjectCompletionHandler)completionHandler;

@end
