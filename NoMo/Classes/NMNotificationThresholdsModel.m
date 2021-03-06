//
//  NMNotificationThresholdsModel.m
//  NoMo
//
//  Created by Costas Harizakis on 07/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMNotificationThresholdsModel.h"
#import "NMNotificationThresholdItem.h"
#import "NMHTTPSessionManager.h"


@interface NMNotificationThresholdsModel ()

@property (nonatomic, copy, readonly) NSString *resourceName;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, strong) NSURLSessionDataTask *loadTask;
@property (nonatomic, strong) NSArray *items; // Array of NMNotificationThresholdItem objects.

@end


@implementation NMNotificationThresholdsModel

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

#pragma mark - [ Methods ]

- (double)minimumAllowedValueForCurrencyCode:(NSString *)currencyCode
{
	NMNotificationThresholdItem *item = [self effectiveItemForCurrencyCode:currencyCode];
	
	return item.minimumAllowedValue;
}

- (double)maximumAllowedValueForCurrencyCode:(NSString *)currencyCode
{
	NMNotificationThresholdItem *item = [self effectiveItemForCurrencyCode:currencyCode];
	
	return item.maximumAllowedValue;
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
				NSLog(@"[NotificationThresholdsModel] [Load completed]");
				
				NSArray *arrayOfProperties = [properties objectOrNilForKey:@"data"];
				self.items = [arrayOfProperties arrayByConvertingPropertiesToItemsOfKind:[NMNotificationThresholdItem class]];
				
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

#pragma mark - [ Private Methods ]

- (NMNotificationThresholdItem *)effectiveItemForCurrencyCode:(NSString *)currencyCode
{
	for (NMNotificationThresholdItem *item in _items) {
		if ([item.currencyCode isEqualToString:currencyCode]) {
			return item;
		}
	}
	
	return [_items firstObjectOrNil];
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
	
	NSLog(@"[NotificationThresholdsModel] [Restoring state (Path: \"%@\")]", path);
	
	_items = [arrayOfProperties arrayByConvertingPropertiesToItemsOfKind:[NMNotificationThresholdItem class]];
	
	return (_items != nil);
}

- (void)saveState
{
	NSString *path = [_resourceName stringByPrependingDefaultCacheDirectory];
	NSArray *arrayOfProperties = [_items arrayByConvertingItemsToProperties] ?: [NSArray array];
	
	NSLog(@"[NotificationThresholdsModel] [Saving state (Path: \"%@\")]", path);
	
	[arrayOfProperties writeToJSONFile:path atomically:YES];
}

@end


@implementation NMNotificationThresholdsModel (Global)

+ (instancetype)defaultModel
{
	static NMNotificationThresholdsModel *instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		NSURL *baseURL = [NoMoSettings contentBaseURL];
		NSString *resourceName = @"model-notification_thresholds.json";
		NSString *resourcePath = [resourceName stringByPrependingPathComponent:@"models"];
		NSURL *resourceURL = [NSURL URLWithString:resourcePath relativeToURL:baseURL];
		
		instance = [[NMNotificationThresholdsModel alloc] initForResourceNamed:resourceName withPath:[resourceURL absoluteString]];		
	});
	
	return instance;
}

@end

