//
//  NMSummaryMessagesModel.m
//  NoMo
//
//  Created by Costas Harizakis on 11/1/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMSummaryMessagesModel.h"
#import "NMSummaryMessageItem.h"
#import "NMHTTPSessionManager.h"


@interface NMSummaryMessagesModel ()

@property (nonatomic, copy, readonly) NSString *resourceName;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, strong) NSURLSessionDataTask *loadTask;
@property (nonatomic, strong) NSArray *items; // Array of NMSummaryMessageItem objects.

@end


@implementation NMSummaryMessagesModel

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[self invalidate];
}

#pragma mark - [ Initializers ]

- (instancetype)init
{
	return [self initForResourceNamed:nil withPath:nil];
}

- (instancetype)initForResourceNamed:(NSString *)resourceName withPath:(NSString *)path
{
	self = [super init];
	
	if (self) {
		_resourceName = [resourceName copy];
		_path = [path copy];
		_loadTask = nil;
		_items = nil;
		
		if ([self restoreState]) {
			[self setLoaded:YES];
		}
	}
	
	return self;
}

#pragma mark - [ NMModel ]

- (void)invalidate
{
	[self cancelLoad];
	
	_items = nil;

	[self saveState];
	[self setModified:NO];
	[self setLoaded:NO];
}

- (BOOL)canLoad
{
	if (_loadTask) {
		return NO;
	}
	
	return YES;
}

- (BOOL)load
{
	if (![self canLoad]) {
		return NO;
	}
	
	NMJSONObjectCompletionHandler completionHandler = ^(NSURLSessionDataTask *task, NSDictionary *properties, NSError *error) {
		if (self.loadTask == task) {
			self.loadTask = nil;
			
			if (error) {
				[self didFailLoadWithError:error];
			}
			else {
				NSLog(@"[SummaryMessagesModel] [Load completed]");
				
				NSArray *arrayOfProperties = [properties objectOrNilForKey:@"data"];
				self.items = [arrayOfProperties arrayByConvertingPropertiesToItemsOfKind:[NMSummaryMessageItem class]];
				
				[self saveState];
				
				[self setModified:NO];
				[self didFinishLoad];
				[self didChange];
			}
		}
	};
	
	NMHTTPSessionManager *manager = [NMHTTPSessionManager manager];
	
	_loadTask = [manager get:_path parameters:nil completed:completionHandler];
	
	if (_loadTask == nil) {
		return NO;
	}
	
	[self didStartLoad];
	
	return YES;
}

- (void)cancelLoad
{
	if (_loadTask) {
		NSURLSessionDataTask *task = _loadTask;
		_loadTask = nil;
		[task cancel];
		[self didCancelLoad];
	}
}

#pragma mark - [ Methods ]

- (NSString *)textWithPersona:(NMApplicationPersona)persona forAmount:(NMAmount *)amount
{
	NSArray *items = [self itemsWithPersona:persona forAmount:amount];
	NSInteger index = [NMUtility randomIntegerWithMaxValue:items.count];
	NMSummaryMessageItem *item = [items objectOrNilAtIndex:index];
	
	return item.text;
}

#pragma mark - [ Private Methods ]

- (NSArray *)itemsWithPersona:(NMApplicationPersona)persona forAmount:(NMAmount *)amount
{
	NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NMSummaryMessageItem *item, NSDictionary *bindings) {
		return [item canUseWithPersona:persona forAmount:amount];
	}];
	NSArray *items = [_items filteredArrayUsingPredicate:predicate];
	
	return items;
}

- (BOOL)restoreState
{
	NSString *path = [_resourceName stringByPrependingDefaultCacheDirectory];
	NSArray *arrayOfProperties = nil;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		arrayOfProperties = [NSArray arrayWithJSONContentsOfFile:path];
	}
		
	if (arrayOfProperties.count == 0) {
		path = [_resourceName stringByPrependingMainBundleResourcePath];
		arrayOfProperties = [NSArray arrayWithJSONContentsOfFile:path];
	}
		
	NSLog(@"[SummaryMessagesModel] [Restoring state (Path: \"%@\")]", path);
	
	_items = [arrayOfProperties arrayByConvertingPropertiesToItemsOfKind:[NMSummaryMessageItem class]];
	
	return (_items != nil);
}

- (void)saveState
{
	NSString *path = [_resourceName stringByPrependingDefaultCacheDirectory];
	NSArray *arrayOfProperties = [_items arrayByConvertingItemsToProperties] ?: [NSArray array];
	
	NSLog(@"[SummaryMessagesModel] [Saving state (Path: \"%@\")]", path);
	
	[arrayOfProperties writeToJSONFile:path atomically:YES];
}

@end


@implementation NMSummaryMessagesModel (Global)

+ (instancetype)summaryHeadingsModel
{
	static NMSummaryMessagesModel *instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		NSURL *baseURL = [NoMoSettings contentBaseURL];
		NSString *resourceName = @"model-summary_messages-headings.json";
		NSString *resourcePath = [resourceName stringByPrependingPathComponent:@"models"];
		NSURL *resourceURL = [NSURL URLWithString:resourcePath relativeToURL:baseURL];

		instance = [[NMSummaryMessagesModel alloc] initForResourceNamed:resourceName withPath:[resourceURL absoluteString]];
	});
	
	return instance;
}

+ (instancetype)summaryCommentsModel
{
	static NMSummaryMessagesModel *instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		NSURL *baseURL = [NoMoSettings contentBaseURL];
		NSString *resourceName = @"model-summary_messages-comments.json";
		NSString *resourcePath = [resourceName stringByPrependingPathComponent:@"models"];
		NSURL *resourceURL = [NSURL URLWithString:resourcePath relativeToURL:baseURL];
		
		instance = [[NMSummaryMessagesModel alloc] initForResourceNamed:resourceName withPath:[resourceURL absoluteString]];
	});
	
	return instance;
}

@end
