//
//  NMPageScrollView.h
//  NoMo
//
//  Created by Costas Harizakis on 9/26/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@class NMDynamicScrollView;

@protocol NMDynamicScrollViewDelegate <UIScrollViewDelegate>

@optional

- (void)scrollViewWillUpdateContentLayout:(NMDynamicScrollView *)scrollView;
- (void)scrollViewDidUpdateContentLayout:(NMDynamicScrollView *)scrollView;

@end


@protocol NMDynamicScrollViewDataSource <NSObject>

- (NSUInteger)numberOfPages;
- (UIView *)viewForPageAtIndex:(NSUInteger)index;

@end


@interface NMDynamicScrollView : UIScrollView

@property (nonatomic, weak) IBOutlet id<NMDynamicScrollViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet id<NMDynamicScrollViewDataSource> datasource;

@property (nonatomic, assign, readonly) NSUInteger numberOfPages;
@property (nonatomic, assign) NSUInteger currentPage;

- (void)willUpdateContentLayout;
- (void)didUpdateContentLayout;

- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)reloadData;

@end
