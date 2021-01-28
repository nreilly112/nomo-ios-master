//
//  NMPageScrollView.m
//  NoMo
//
//  Created by Costas Harizakis on 9/26/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMDynamicScrollView.h"


@interface NMDynamicScrollView ()

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, assign) BOOL layoutContent;

- (void)setNeedsContentLayout;
- (void)updateContentLayoutIfNeeded;
- (void)updateContentLayout;

@end


@implementation NMDynamicScrollView

@dynamic delegate;

#pragma mark - [ Initializers ]

- (void)awakeFromNib
{
	[super awakeFromNib];
}

#pragma mark - [ Properties ]

- (NSUInteger)numberOfPages
{
	return _contentView.subviews.count;
}

- (NSUInteger)currentPage
{
	CGFloat pageWidth = self.width;
	CGFloat contentWidth = self.contentSize.width;
	CGFloat contentOffsetX = MIN(MAX(0.0, self.contentOffset.x - 0.5 * pageWidth), contentWidth);
	NSUInteger pageIndex = ceil(contentOffsetX / pageWidth);
	
	return pageIndex;
}

- (void)setCurrentPage:(NSUInteger)currentPage
{
	[self scrollToPageAtIndex:currentPage animated:NO];
}

#pragma mark - [ Private Properties ]

- (UIView *)contentView
{
	if (_contentView == nil) {
		UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
		[self addSubview:contentView];
		
		_contentView = contentView;
	}
	
	return _contentView;
}

#pragma mark - [ Events ]

- (void)willUpdateContentLayout
{
	if ([self.delegate respondsToSelector:@selector(scrollViewWillUpdateContentLayout:)]) {
		[self.delegate scrollViewWillUpdateContentLayout:self];
	}
}

- (void)didUpdateContentLayout
{
	if ([self.delegate respondsToSelector:@selector(scrollViewDidUpdateContentLayout:)]) {
		[self.delegate scrollViewDidUpdateContentLayout:self];
	}
}

#pragma mark - [ Methods ]

- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated
{
	CGSize pageSize = self.size;
	CGPoint pageOrigin = CGPointMake(index * pageSize.width, 0.0);
	CGRect pageRect = CGRectMakeWithOriginSize(pageOrigin, pageSize);
	
	[self scrollRectToVisible:pageRect animated:animated];
}

- (void)reloadData
{
	UIView *contentView = self.contentView;
	[_contentView removeAllSubviews];
	
	NSUInteger pageCount = [_datasource numberOfPages];
	
	for (NSUInteger pageIndex = 0; pageIndex < pageCount; pageIndex += 1) {
		UIView *page = [_datasource viewForPageAtIndex:pageIndex];
		[contentView addSubview:page];
	}
	
	[self setNeedsContentLayout];
	[self setNeedsLayout];
}

#pragma mark - [ UIView Methods ]

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self updateContentLayoutIfNeeded];
}

#pragma mark - [ Private Methods ]

- (void)setNeedsContentLayout
{
	_layoutContent = YES;
}

- (void)updateContentLayoutIfNeeded
{
	NSArray *slides = _contentView.subviews;
	CGSize slideSize = self.size;
	CGSize contentSize = CGSizeScale(slideSize, slides.count, 1.0);

	if (!CGSizeEqualToSize(contentSize, _contentView.size)) {
		[self updateContentLayout];
	}
	if (_layoutContent) {
		[self updateContentLayout];
	}
}

- (void)updateContentLayout
{
	[self willUpdateContentLayout];
	
	NSArray *pages = _contentView.subviews;
	CGSize pageSize = self.size;
	CGPoint pageOrigin = CGPointZero;
	
	for (UIView *page in pages) {
		page.frame = CGRectMakeWithOriginSize(pageOrigin, pageSize);
		pageOrigin = CGPointOffset(pageOrigin, pageSize.width, 0.0);
	}
	
	CGSize contentSize = CGSizeScale(pageSize, pages.count, 1.0);
	self.contentSize = _contentView.size = contentSize;
	
	_layoutContent = NO;
	
	[self didUpdateContentLayout];
}

@end
