//
//  NoMoHTTPSessionManager+User.m
//  NoMo
//
//  Created by Costas Harizakis on 10/5/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NoMoHTTPSessionManager.h"
#import "NMSession.h"


@implementation NoMoHTTPSessionManager (Session)

- (NSURLSessionDataTask *)getSessionValidationStateForUserWithIdentity:(id<NMIdentity>)userIdentity
													 completionHandler:(NMJSONObjectCompletionHandler)completionHandler;
{
    NSLog(@"[NoMoHTTPSessionManager]: getSessionValidationStateForUserWithIdentity - DO NOTHING FOR NOW");
	// NOTE: Replaced the relative path with an absolute one. This is a temporary
	// hack to handle a poor design choice on the backend routing scheme.
	//
	// NSString *path = [NSString stringWithFormat:@"./user/events/"];
	//
	// --harizak (2017-03-29)
	NSString *path = [NSString stringWithFormat:@"/nomo/public/events/safe"];
	NSDictionary *parameters = @{ @"referenceToken": @"" ?: [NSNull null],
								  @"sessionId": userIdentity.grantType ?: [NSNull null] };
	NSData *data = [parameters JSONData];
	
	return [self post:path data:data completed:^(NSURLSessionDataTask *task, id json, NSError *error) {
		if (error == nil) {
			NSArray *arrayOfObjects = [self olderToNewerArrayOfObjects:json];
			NSDictionary *object = [arrayOfObjects lastObjectOrNil];
			
			if (arrayOfObjects.count) {
				NSLog(@"[NoMoHTTPSessionmanager] [Events received (dump follows)]");
				NSLog(@"\n%@", ((NSArray *)json).description);
			}
#if 0
			object = @{ @"hasError": @(1),
						@"errorCode": @(417),
						@"errorMessage": @"(error message)" };
#endif
			if (object == nil) {
				NSDictionary *properties = @{ @"state": [NSNumber numberWithInteger:NMSessionVerificationStateUnknown],
											  @"index": [NSNumber numberWithInteger:NSNotFound] };
				completionHandler(task, properties, nil);
			}
			else if ([object integerValueOrZeroForKey:@"hasError"]) {
				NSInteger errorCode = [object integerValueOrZeroForKey:@"errorCode"];
				NSString *errorMessage = [object objectOrNilForKey:@"errorMessage"];
				NSDictionary *errorInfo = @{ @"code": [NSNumber numberWithInteger:errorCode],
											 @"message": errorMessage };
				NMSessionVerificationState verificationState = NMSessionVerificationStateFromErrorCode(errorCode);
				NSError *error = [NSError errorWithDomain:@"Verification" code:-1 userInfo:errorInfo];
				NSDictionary *properties = @{ @"state": [NSNumber numberWithInteger:verificationState],
											  @"index": [NSNumber numberWithInteger:(arrayOfObjects.count - 1)],
											  @"error": error };
				completionHandler(task, properties, nil);
			}
			else /* success */ {
				NSDictionary *properties = @{ @"state": [NSNumber numberWithInteger:NMSessionVerificationStateApproved],
											  @"index": [NSNumber numberWithInteger:(arrayOfObjects.count - 1)] };
				completionHandler(task, properties, nil);
			}
		}
		else {
			completionHandler(task, nil, error);
		}
	}];
    

}

- (NSURLSessionDataTask *)invalidateSessionForUserWithIdentity:(id<NMIdentity>)userIdentity
											 completionHandler:(NMCompletionHandler)completionHandler
{
	NSString *path = [NSString stringWithFormat:@"./user/logout"];
	NSDictionary *parameters = @{ };
	
	return [self put:path parameters:parameters completed:^(NSURLSessionDataTask *task, NSError *error) {
		if (error == nil) {
			completionHandler(task, nil);
		}
		else {
			completionHandler(task, error);
		}
	}];
}

#pragma mark - [ Private Methods ]

- (NSArray *)olderToNewerArrayOfObjects:(NSArray *)arrayOfObjects
{
	NSArray *sortedArray = [arrayOfObjects sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
		NSTimeInterval timestamp1 = [self timestampOfObject:obj1];
		NSTimeInterval timestamp2 = [self timestampOfObject:obj2];
		
		if (timestamp1 < timestamp2) {
			return NSOrderedAscending;
		}
		else if (timestamp1 > timestamp2) {
			return NSOrderedDescending;
		}
		else {
			return NSOrderedSame;
		}
	}];
	
	return sortedArray;
}

- (NSTimeInterval)timestampOfObject:(NSDictionary *)object
{
	return [object doubleValueOrZeroForKey:@"updatedAt"];
}

@end
