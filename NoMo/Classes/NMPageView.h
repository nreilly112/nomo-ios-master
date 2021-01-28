//
//  NMPageView.h
//  NoMo
//
//  Created by Costas Harizakis on 10/19/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@class NMPageView;

@protocol  NMPageViewDelegate <NSObject>

@optional

- (void)pageViewDidStartScrolling:(NMPageView *)pageView;
- (void)pageViewDidEndScrolling:(NMPageView *)pageView;
- (void)pageView:(NMPageView *)pageView didScrollToPageAtIndex:(NSUInteger)index;

@end


@interface NMPageView : UIView

@property (nonatomic, weak) IBOutlet id<NMPageViewDelegate> delegate;

@property (nonatomic, assign, readonly) NSUInteger numberOfPages;
@property (nonatomic, assign) NSUInteger currentPage;

- (void)didStartScrolling;
- (void)didEndScrolling;
- (void)didScrollToPageAtIndex:(NSUInteger)index;

@end
