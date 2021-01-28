//
//  NMModel.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@protocol NMModel;
@protocol NMModelDelegate;

@class NMModel;


@protocol NMModelDelegate <NSObject>

@optional

- (void)modelDidChange:(id<NMModel>)model;

- (void)modelDidStartLoad:(id<NMModel>)model;
- (void)modelDidCancelLoad:(id<NMModel>)model;
- (void)modelDidFinishLoad:(id<NMModel>)model;
- (void)model:(id<NMModel>)model didFailLoadWithError:(NSError *)error;

- (void)modelDidStartSave:(id<NMModel>)model;
- (void)modelDidCancelSave:(id<NMModel>)model;
- (void)modelDidFinishSave:(id<NMModel>)model;
- (void)model:(id<NMModel>)model didFailSaveWithError:(NSError *)error;
- (void)model:(id<NMModel>)model didSaveData:(double)fraction bytes:(int64_t)bytes totalBytes:(int64_t)totalBytes;

@end


@protocol NMModel <NSObject>

@property (nonatomic, assign, getter = isModified) BOOL modified;
@property (nonatomic, assign, getter = isLoaded) BOOL loaded;
@property (nonatomic, copy, readonly) NSArray *delegates;

- (void)addDelegate:(id<NMModelDelegate>)delegate;
- (void)removeDelegate:(id<NMModelDelegate>)delegate;
- (void)removeAllDelegates;

- (void)beginUpdates;
- (void)endUpdates;


@optional

@property (nonatomic, assign, readonly, getter = isLoading) BOOL loading;
@property (nonatomic, assign, readonly, getter = isSaving) BOOL saving;

- (void)invalidate;

- (BOOL)canLoad;
- (BOOL)load;
- (void)cancelLoad;

- (BOOL)canSave;
- (BOOL)save;
- (void)cancelSave;

@end


@interface NMModel : NSObject <NMModel>

@property (nonatomic, assign, getter = isModified) BOOL modified;
@property (nonatomic, assign, getter = isLoaded) BOOL loaded;
@property (nonatomic, assign, readonly, getter = isLoading) BOOL loading;
@property (nonatomic, assign, readonly, getter = isSaving) BOOL saving;
@property (nonatomic, copy, readonly) NSArray *delegates;

- (void)addDelegate:(id<NMModelDelegate>)delegate;
- (void)removeDelegate:(id<NMModelDelegate>)delegate;
- (void)removeAllDelegates;

- (void)beginUpdates;
- (void)endUpdates;

- (void)didChange;

- (BOOL)canLoad;
- (BOOL)load;
- (void)cancelLoad;
- (void)invalidate;

- (void)didStartLoad;
- (void)didCancelLoad;
- (void)didFinishLoad;
- (void)didFailLoadWithError:(NSError *)error;

- (BOOL)canSave;
- (BOOL)save;
- (void)cancelSave;

- (void)didStartSave;
- (void)didCancelSave;
- (void)didFinishSave;
- (void)didFailSaveWithError:(NSError *)error;
- (void)didSaveData:(double)fractionCompleted bytes:(int64_t)bytesSaved totalBytes:(int64_t)totalBytesToBeSaved;

@end


@protocol NMListModel;
@protocol NMListModelDelegate;

@class NMListModel;


@protocol NMListModelDelegate <NMModelDelegate>

@optional

- (void)model:(id<NMModel>)model didInsertItem:(id)item atIndex:(NSUInteger)index;
- (void)model:(id<NMModel>)model didUpdateItem:(id)existingItem atIndex:(NSUInteger)index withItem:(id)item;
- (void)model:(id<NMModel>)model didDeleteItem:(id)existingItem atIndex:(NSUInteger)index;

@end


@protocol NMListModel <NMModel>

@property (nonatomic, strong, readonly) NSArray *items;
@property (nonatomic, assign, readonly) NSUInteger count;

- (id)itemAtIndex:(NSUInteger)index;

@optional

- (BOOL)insertItem:(id)item atIndex:(NSUInteger)index;
- (BOOL)updateItemAtIndex:(NSUInteger)index withItem:(id)item;
- (BOOL)deleteItemAtIndex:(NSUInteger)index;

@end


@interface NMListModel : NMModel <NMListModel>

@property (nonatomic, strong, readonly) NSArray *items;
@property (nonatomic, assign, readonly) NSUInteger count;

- (id)itemAtIndex:(NSUInteger)index;

- (void)didInsertItem:(id)item atIndex:(NSUInteger)index;
- (void)didUpdateItem:(id)existingItem atIndex:(NSUInteger)index withItem:(id)item;
- (void)didDeleteItem:(id)existingItem atIndex:(NSUInteger)index;

@end
