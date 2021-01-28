//
//  NMModel.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMModel.h"


@interface NMModel ()
{
	NSMutableArray *_delegates;
}

@property (nonatomic, assign) NSUInteger updateDepth;
@property (nonatomic, assign) BOOL delayedModified;
@property (nonatomic, assign) BOOL delayedDidChange;

@end


@implementation NMModel

@synthesize delegates = _delegates;

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[_delegates removeAllObjects];
}

#pragma mark - [ Initializer ]

- (instancetype)init
{
	self = [super init];
	
	if (self) {
		_delegates = [NSMutableArray nonRetainingArray];
		_modified = NO;
		_loaded = NO;
		_loading = NO;
		_saving = NO;
	}
	
	return self;
}

#pragma mark - [ Properties ]

- (NSArray *)delegates
{
	NSMutableArray *delegates = [NSMutableArray nonRetainingArray];
	[delegates addObjectsFromArray:_delegates];
	
	return delegates;
}

- (void)setModified:(BOOL)modified
{
	if (_updateDepth != 0) {
		_delayedModified = modified;
		return;
	}
	
	if (_modified != modified) {
		[self willChangeValueForKey:@"modified"];
		_modified = modified;
		[self didChangeValueForKey:@"modified"];
	}
}

- (void)setLoaded:(BOOL)loaded
{
	if (_loaded != loaded) {
		[self willChangeValueForKey:@"loaded"];
		_loaded = loaded;
		[self didChangeValueForKey:@"loaded"];
	}
}

- (void)setLoading:(BOOL)loading
{
	if (_loading != loading) {
		[self willChangeValueForKey:@"loading"];
		_loading = loading;
		[self didChangeValueForKey:@"loading"];
	}
}

- (void)setSaving:(BOOL)saving
{
	if (_saving != saving) {
		[self willChangeValueForKey:@"saving"];
		_saving = saving;
		[self didChangeValueForKey:@"saving"];
	}
}

#pragma mark - [ Methods ]

- (void)addDelegate:(id<NMModelDelegate>)delegate
{
	if (delegate) {
		[_delegates addObject:delegate];
	}
}

- (void)removeDelegate:(id<NMModelDelegate>)delegate
{
	if (delegate) {
		[_delegates removeObject:delegate];
	}
}

- (void)removeAllDelegates
{
	[_delegates removeAllObjects];
}

#pragma mark - [ Methods (Events) ]

- (void)didChange
{
	if (_updateDepth != 0) {
		_delayedDidChange = YES;
		return;
	}
	
	for (id delegate in self.delegates) {
		[self performBlockOnMainThread:^(void) {
			if ([delegate respondsToSelector:@selector(modelDidChange:)]) {
				[delegate modelDidChange:self];
			}
		}];
	}
}

- (void)didStartLoad
{
	if (self.isLoading) {
		return;
	}

	self.loading = YES;
	
	for (id delegate in self.delegates) {
		[self performBlockOnMainThread:^(void) {
			if ([delegate respondsToSelector:@selector(modelDidStartLoad:)]) {
					[delegate modelDidStartLoad:self];
				}
		}];
	}
}

- (void)didCancelLoad
{
	if (!self.isLoading) {
		return;
	}

	self.loading = NO;
	
	for (id delegate in self.delegates) {
		[self performBlockOnMainThread:^(void) {
			if ([delegate respondsToSelector:@selector(modelDidCancelLoad:)]) {
				[delegate modelDidCancelLoad:self];
			}
		}];
	}
}

- (void)didFinishLoad
{
	if (!self.isLoading) {
		return;
	}

	self.loading = NO;
	self.loaded = YES;
	
	for (id delegate in self.delegates) {
		[self performBlockOnMainThread:^(void) {
			if ([delegate respondsToSelector:@selector(modelDidFinishLoad:)]) {
				[delegate modelDidFinishLoad:self];
			}
		}];
	}
}

- (void)didFailLoadWithError:(NSError *)error
{
	if (!self.isLoading) {
		return;
	}

	self.loading = NO;
	
	for (id delegate in self.delegates) {
		[self performBlockOnMainThread:^(void) {
			if ([delegate respondsToSelector:@selector(model:didFailLoadWithError:)]) {
				[delegate model:self didFailLoadWithError:error];
			}
		}];
	}
}

- (void)didStartSave
{
	if (self.isSaving) {
		return;
	}

	self.saving = YES;
	
	for (id delegate in self.delegates) {
		[self performBlockOnMainThread:^(void) {
			if ([delegate respondsToSelector:@selector(modelDidStartSave:)]) {
				[delegate modelDidStartSave:self];
			}
		}];
	}
}

- (void)didCancelSave
{
	if (!self.isSaving) {
		return;
	}
	
	self.saving = NO;
	
	for (id delegate in self.delegates) {
		[self performBlockOnMainThread:^(void) {
			if ([delegate respondsToSelector:@selector(modelDidCancelSave:)]) {
				[delegate modelDidCancelSave:self];
			}
		}];
	}
}

- (void)didFinishSave
{
	if (!self.isSaving) {
		return;
	}
	
	self.saving = NO;
	
	for (id delegate in self.delegates) {
		[self performBlockOnMainThread:^(void) {
			if ([delegate respondsToSelector:@selector(modelDidFinishSave:)]) {
				[delegate modelDidFinishSave:self];
			}
		}];
	}
}

- (void)didFailSaveWithError:(NSError *)error
{
	if (!self.isSaving) {
		return;
	}
	
	self.saving = NO;
	
	for (id delegate in self.delegates) {
		[self performBlockOnMainThread:^(void) {
			if ([delegate respondsToSelector:@selector(model:didFailSaveWithError:)]) {
				[delegate model:self didFailSaveWithError:error];
			}
		}];
	}
}

- (void)didSaveData:(double)fractionCompleted bytes:(int64_t)bytes totalBytes:(int64_t)totalBytes
{
	if (!self.isSaving) {
		return;
	}
	
	for (id delegate in self.delegates) {
		[self performBlockOnMainThread:^(void) {
			if ([delegate respondsToSelector:@selector(model:didSaveData:bytes:totalBytes:)]) {
				[delegate model:self didSaveData:fractionCompleted bytes:bytes totalBytes:totalBytes];
			}
		}];
	}
}

#pragma mark - [ Methods ]

- (void)beginUpdates
{
	if (_updateDepth == 0) {
		_delayedModified = self.isModified;
	}
	
	_updateDepth += 1;
}

- (void)endUpdates
{
	_updateDepth -= 1;
	
	if (_updateDepth == 0) {
		self.modified = _delayedModified;
		
		if (_delayedDidChange) {
			_delayedDidChange = NO;
			[self didChange];
		}
	}
}

- (BOOL)canLoad
{
	return NO;
}

- (BOOL)load
{
	return NO;
}

- (void)cancelLoad
{
	// Nothing to be done here.
}

- (void)invalidate
{
	self.modified = NO;
	self.loaded = NO;
}

- (BOOL)canSave
{
	return NO;
}

- (BOOL)save
{
	return NO;
}

- (void)cancelSave
{
	// Nothing to be done here.
}

#pragma mark - [ NSKeyValueObserving ]

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
	return NO;
}

@end


@implementation NMListModel

#pragma mark - [ Initializers ]

- (instancetype)init
{
	self = [super init];
	
	if (self) {
		// Additional initialization.
	}
	
	return self;
}

#pragma mark - [ Properties ]

- (NSArray *)items
{
	return [NSArray array];
}

- (NSUInteger)count
{
	return 0;
}

#pragma mark - [ Methods ]

- (id)itemAtIndex:(NSUInteger)index
{
	return nil;
}

#pragma mark - [ Methods (Events) ]

- (void)didInsertItem:(id)item atIndex:(NSUInteger)index
{
	if (self.updateDepth != 0) {
		self.delayedDidChange = YES;
		return;
	}
	
	for (id delegate in self.delegates) {
		[self performBlockOnMainThread:^(void) {
			if ([delegate respondsToSelector:@selector(model:didInsertItem:atIndex:)]) {
				[delegate model:self didInsertItem:item atIndex:index];
			}
		}];
	}
}

- (void)didUpdateItem:(id)existingItem atIndex:(NSUInteger)index withItem:(id)item
{
	if (self.updateDepth != 0) {
		self.delayedDidChange = YES;
		return;
	}
	
	for (id delegate in self.delegates) {
		[self performBlockOnMainThread:^(void) {
			if ([delegate respondsToSelector:@selector(model:didUpdateItem:atIndex:withItem:)]) {
				[delegate model:self didUpdateItem:existingItem atIndex:index withItem:item];
			}
		}];
	}
}

- (void)didDeleteItem:(id)existingItem atIndex:(NSUInteger)index
{
	if (self.updateDepth != 0) {
		self.delayedDidChange = YES;
		return;
	}
	
	for (id delegate in self.delegates) {
		[self performBlockOnMainThread:^(void) {
			if ([delegate respondsToSelector:@selector(model:didDeleteItem:atIndex:)]) {
				[delegate model:self didDeleteItem:existingItem atIndex:index];
			}
		}];
	}
}

@end

