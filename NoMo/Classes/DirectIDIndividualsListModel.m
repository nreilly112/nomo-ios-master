//
//  DirectIDIndividualsListModel.m
//  NoMo
//
//  Created by Costas Harizakis on 9/29/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "DirectIDIndividualsListModel.h"
#import "DirectIDHTTPSessionManager.h"


@interface DirectIDIndividualsListModel ()

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSURLSessionTask *loadTask;

@end


@implementation DirectIDIndividualsListModel

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[self cancelLoad];
}

#pragma mark - [ Initializer ]

- (instancetype)init
{
	return [self initWithAuthority:nil];
}

- (instancetype)initWithAuthority:(NSString *)authority
{
	self = [super init];
	
	if (self) {
		_items = nil;
		_loadTask = nil;
	}
	
	return self;
}

#pragma mark - [ NMListModel Properties ]

- (NSArray *)items
{
	return _items ?: [NSArray array];
}

- (NSUInteger)count
{
	return _items.count;
}

#pragma mark - [ NMListModel Methods ]

- (id)itemAtIndex:(NSUInteger)index
{
	return [_items objectOrNilAtIndex:index];
}

#pragma mark - [ NMModel Methods ]

- (void)invalidate
{
	[super invalidate];
	[self cancelLoad];
	
	_items = nil;
}

- (BOOL)load
{
	if (_loadTask) {
		return NO;
	}
	
	NMJSONArrayCompletionHandler completionHandler = ^(NSURLSessionDataTask *task, NSArray *arrayOfProperties, NSError *error) {
		if (_loadTask == task) {
			_loadTask = nil;
			
			if (error) {
				[self didFailLoadWithError:error];
			}
			else {
				_items = [arrayOfProperties arrayByConvertingPropertiesToItemsOfKind:[NMIndividualItem class]];
				
				[self setModified:NO];
				[self didFinishLoad];
				[self didChange];
			}
		}
	};
	
	DirectIDHTTPSessionManager *manager = [DirectIDHTTPSessionManager defaultManager];
	
	_loadTask = [manager getIndividualsWithCompletionHandler:completionHandler];
	
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
