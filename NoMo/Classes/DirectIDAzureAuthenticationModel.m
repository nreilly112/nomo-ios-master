//
//  DirectIDAuthenticationModel.m
//  NoMo
//
//  Created by Costas Harizakis on 10/18/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "DirectIDAzureAuthenticationModel.h"
#import	"DirectIDSecurityContext.h"
#import "DirectIDOAuth2Settings.h"


@implementation DirectIDAzureAuthenticationModel

#pragma mark - [ Static Methods ]

+ (instancetype)sharedModel
{
	static DirectIDAzureAuthenticationModel *instance;
	static dispatch_once_t once;
	
	dispatch_once(&once, ^(void) {
		DirectIDSecurityContext *securityContext = [DirectIDSecurityContext defaultContext];
		
		instance = [[DirectIDAzureAuthenticationModel alloc] initWithSecurityContext:securityContext
																	  usingAuthority:[DirectIDOAuth2Settings authority]];
		instance.resource = [DirectIDOAuth2Settings resourceName];
		instance.credentials = [NMOAuth2Credentials credentialsWithClientId:[DirectIDOAuth2Settings clientIdentifier]
															   clientSecret:[DirectIDOAuth2Settings clientSecret]];
	});
	
	return instance;
}

@end
