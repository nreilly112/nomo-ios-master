//
//  NMPageView.m
//  NoMo
//
//  Created by Costas Harizakis on 10/19/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMPageView.h"
#import "NMPageScrollView.h"
#import "SMPageControl.h"


@interface NMPageView () <NMPageScrollViewDelegate>

@property (nonatomic, weak) IBOutlet NMPageScrollView *scrollView;
@property (nonatomic, weak) IBOutlet SMPageControl *pageControl;

@property (nonatomic, assign, getter = isScrolling) BOOL scrolling;
@property (nonatomic, assign) NSUInteger lastPageIndex;

- (IBAction)didChangePageControlValue:(id)sender;

- (void)updateScrollingState;
- (void)updatePageControlState;
- (void)updateScrollViewStateAnimated:(BOOL)animated;

@end


@implementation NMPageView

#pragma mark - [ Initializer ]

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	_lastPageIndex = NSNotFound;
	
	_pageControl.indicatorMargin = 9.0;
	_pageControl.indicatorDiameter = 7.0;
	_pageControl.pageIndicatorTintColor = [UIColor colorWithRGB:0x666666];
	_pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
	_pageControl.numberOfPages = 0;
	_pageControl.currentPage = 0;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self updateScrollViewStateAnimated:NO];
}

#pragma mark - [ Properties ]

- (NSUInteger)numberOfPages
{
	return _pageControl.numberOfPages;
}

- (NSUInteger)currentPage
{
	return _pageControl.currentPage;
}

- (void)setCurrentPage:(NSUInteger)currentPage
{
	_pageControl.currentPage = _scrollView.currentPage = currentPage;
}

#pragma mark - [ Events ]

- (void)didStartScrolling
{
	if ([self.delegate respondsToSelector:@selector(pageViewDidStartScrolling:)]) {
		[self.delegate pageViewDidStartScrolling:self];
	}
}

- (void)didEndScrolling
{
	if ([self.delegate respondsToSelector:@selector(pageViewDidEndScrolling:)]) {
		[self.delegate pageViewDidEndScrolling:self];
	}
}

- (void)didScrollToPageAtIndex:(NSUInteger)index
{
	if ([self.delegate respondsToSelector:@selector(pageView:didScrollToPageAtIndex:)]) {
		[self.delegate pageView:self didScrollToPageAtIndex:index];
	}
}

#pragma mark - [ Actions ]

- (void)didChangePageControlValue:(id)sender
{
	[self updateScrollViewStateAnimated:YES];
}

#pragma mark - [ UIScrollViewDelegate ]

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self updateScrollingState];
	
	if (_scrollView.isDragging) {
		[self updatePageControlState];
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	[self updateScrollingState];
	[self updatePageControlState];
	[self didUpdateCurrentPage];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[self updateScrollingState];

	if (!decelerate) {
		[self didUpdateCurrentPage];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self updateScrollingState];
	[self didUpdateCurrentPage];
}

#pragma mark - [ NMPageScrollViewDelegate ]

- (void)scrollView:(NMPageScrollView *)scrollView didUpdateContentSize:(CGSize)contentSize
{
	_pageControl.numberOfPages = _scrollView.numberOfPages;
	[self updateScrollViewStateAnimated:NO];
	_pageControl.currentPage = _scrollView.currentPage;

}

#pragma mark - [ Private Methods]

- (void)updateScrollingState
{
	BOOL scrolling = _scrollView.isDragging || _scrollView.isDecelerating;
	
	if (!_scrolling && scrolling) {
		_scrolling = YES;
		[self didStartScrolling];
	}
	else if (_scrolling && !scrolling) {
		_scrolling = NO;
		[self didEndScrolling];
	}
}

- (void)updatePageControlState
{
	_pageControl.currentPage = _scrollView.currentPage;
}

- (void)updateScrollViewStateAnimated:(BOOL)animated
{
	[_scrollView scrollToPageAtIndex:_pageControl.currentPage animated:animated];
}

- (void)didUpdateCurrentPage
{
	NSUInteger currentPageIndex = _pageControl.currentPage;
	
	if (_lastPageIndex != currentPageIndex) {
		_lastPageIndex = currentPageIndex;
		[self didScrollToPageAtIndex:_lastPageIndex];
	}
}

@end
