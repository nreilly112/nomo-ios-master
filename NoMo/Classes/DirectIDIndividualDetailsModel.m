//
//  DirectIDIndividualDetailsModel.m
//  NoMo
//
//  Created by Costas Harizakis on 9/29/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "DirectIDIndividualDetailsModel.h"
#import "DirectIDHTTPSessionManager.h"


@interface DirectIDIndividualDetailsModel ()

@property (nonatomic, strong) NMIndividualDetailsItem *item;
@property (nonatomic, strong) NSURLSessionTask *loadTask;

@end


@implementation DirectIDIndividualDetailsModel

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[self cancelLoad];
}

#pragma mark - [ Initializer ]

- (instancetype)init
{
	return [self initWithReference:nil];
}

- (instancetype)initWithReference:(NSString *)reference
{
	self = [super init];
	
	if (self) {
		_reference = [reference copy];
		_item = nil;
		_loadTask = nil;
	}
	
	return self;
}

#pragma mark - [ NMModel Methods ]

- (void)invalidate
{
	[super invalidate];
	[self cancelLoad];
	
	_item = nil;
}

- (BOOL)load
{
	if (_loadTask) {
		return NO;
	}
	
	NMJSONObjectCompletionHandler completionHandler = ^(NSURLSessionDataTask *task, NSDictionary *properties, NSError *error) {
		if (_loadTask == task) {
			_loadTask = nil;
			
			if (error) {
				[self didFailLoadWithError:error];
			}
			else {
				_item = [[NMIndividualDetailsItem alloc] initWithProperties:properties];
				
				[self setModified:NO];
				[self didFinishLoad];
				[self didChange];
			}
		}
	};
	
	DirectIDHTTPSessionManager *manager = [DirectIDHTTPSessionManager defaultManager];
	
	_loadTask = [manager getDetailsForIndividualWithReference:_reference
											completionHandler:completionHandler];
	
	if (!_loadTask) {
		return NO;
	}
	
	[_loadTask resume];
	[self didStartLoad];
	
	return YES;
}

- (void)cancelLoad
{
	if (_loadTask) {
		NSURLSessionTask *task = _loadTask;
		_loadTask = nil;
		
		[task cancel];
		
		[self didCancelLoad];
	}
}

@end
