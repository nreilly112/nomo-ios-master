//
//  NMPageScrollView.h
//  NoMo
//
//  Created by Costas Harizakis on 10/19/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@class NMPageScrollView;

@protocol NMPageScrollViewDelegate <UIScrollViewDelegate>

@optional

- (void)scrollView:(NMPageScrollView *)scrollView didUpdateContentSize:(CGSize)contentSize;

@end


@interface NMPageScrollView : UIScrollView

@property (nonatomic, weak) IBOutlet id<NMPageScrollViewDelegate> delegate;

@property (nonatomic, assign, readonly) NSUInteger numberOfPages;
@property (nonatomic, assign) NSUInteger currentPage;

- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated;

- (void)didUpdateContentSize:(CGSize)contentSize;

@end
