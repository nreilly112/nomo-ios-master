//
//  NMViewModel.h
//  NoMo
//
//  Created by Costas Harizakis on 9/24/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@protocol NMViewModel;
@protocol NMViewModelDelegate;


@protocol NMViewModelDelegate <NSObject>

@optional

- (void)viewModelDidChange:(id<NMViewModel>)viewModel;

@end


@protocol NMViewModel <NSObject>

@property (nonatomic, strong, readonly) NSDictionary *errors;
@property (nonatomic, weak) id<NMViewModelDelegate> delegate;

- (BOOL)isModified;
- (BOOL)isValid;

@end


@interface NMViewModel : NSObject <NMViewModel>

@property (nonatomic, strong, readonly) NSDictionary *errors;
@property (nonatomic, weak) IBOutlet id<NMViewModelDelegate> delegate;

- (void)didChange;

- (void)beginUpdates;
- (void)endUpdates;

- (BOOL)isModified;
- (void)clearModified;

- (void)setNeedsValidation;
- (void)validateIfNeeded;
- (void)validate;

- (void)setErrorMessage:(NSString *)message forKey:(NSString *)key;
- (void)setError:(NSError *)error forKey:(NSString *)key;
- (void)removeAllErrors;

- (BOOL)isValid;

// protected

- (void)performValidation;

@end