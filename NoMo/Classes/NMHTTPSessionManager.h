//
//  NMHTTPSessionManager.h
//  NoMo
//
//  Created by Costas Harizakis on 10/4/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "NMSecurityContext.h"


@interface NMHTTPSessionManager : AFHTTPSessionManager

@property (nonatomic, strong, readonly) NMSecurityContext *securityContext;

- (instancetype)initWithBaseURL:(NSURL *)url
		   sessionConfiguration:(NSURLSessionConfiguration *)configuration
				securityContext:(NMSecurityContext *)securityContext;

@end
