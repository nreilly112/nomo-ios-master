//
//  NMImageListModel.m
//  NoMo
//
//  Created by Costas Harizakis on 07/12/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMImageListModel.h"
#import "NMHTTPSessionManager.h"


@interface NMImageListModel ()

@property (nonatomic, copy, readonly) NSString *resourceName;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, strong) NSURLSessionDataTask *loadTask;
@property (nonatomic, strong) NSArray *items; // Array of NSString objects.

@end


@implementation NMImageListModel

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

#pragma mark - [ NMListModel ]

- (NSArray *)items
{
	return _items ?: [NSArray array];
}

- (NSUInteger)count
{
	return _items.count;
}

- (id)itemAtIndex:(NSUInteger)index
{
	return [_items objectOrNilAtIndex:index];
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
				NSLog(@"[ImageListModel] [Load completed]");
				
				self.items = [properties objectOrNilForKey:@"data"];
				
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
	if (self.loadTask) {
		NSURLSessionDataTask *task = _loadTask;
		self.loadTask = nil;
		[task cancel];
		[self didCancelLoad];
	}
}

#pragma mark - [ Private Methods ]

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
	
	NSLog(@"[NMImageListModel] [Restoring state (Path: \"%@\")]", path);
	
	_items = arrayOfProperties;
	
	return (_items != nil);
}

- (void)saveState
{
	NSString *path = [_resourceName stringByPrependingDefaultCacheDirectory];
	NSArray *arrayOfProperties = _items ?: [NSArray array];
	
	NSLog(@"[NMImageListModel] [Saving state (Path: \"%@\")]", path);
	
	[arrayOfProperties writeToJSONFile:path atomically:YES];
}

@end


@implementation NMImageListModel (Global)

+ (instancetype)welcomeImagesModel
{
	static NMImageListModel *instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		NSURL *baseURL = [NoMoSettings contentBaseURL];
		NSString *resourceName = @"model-welcome_images.json";
		NSString *resourcePath = [resourceName stringByPrependingPathComponent:@"models"];
		NSURL *resourceURL = [NSURL URLWithString:resourcePath relativeToURL:baseURL];
		
		instance = [[NMImageListModel alloc] initForResourceNamed:resourceName withPath:[resourceURL absoluteString]];
	});
	
	return instance;
}

@end
