//
//  NMPageScrollView.m
//  NoMo
//
//  Created by Costas Harizakis on 10/19/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMPageScrollView.h"


@interface NMPageScrollView ()

@property (nonatomic, weak) IBOutlet UIView *contentView;

@end


@implementation NMPageScrollView

@dynamic delegate;

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"contentSize"];
}

#pragma mark - [ Initializers ]

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
}

#pragma mark - [ Properties ]

- (NSUInteger)numberOfPages
{
	CGFloat pageWidth = self.width;
	CGFloat contentWidth = self.contentSize.width;
	NSUInteger pageCount = ceil(contentWidth / pageWidth);
	
	return pageCount;
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

#pragma mark - [ Methods ]

- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated
{
	CGSize pageSize = self.size;
	CGPoint pageOrigin = CGPointMake(index * pageSize.width, 0.0);
	CGRect pageRect = CGRectMakeWithOriginSize(pageOrigin, pageSize);
	
	[self scrollRectToVisible:pageRect animated:animated];
}

#pragma mark - [ Events ]

- (void)didUpdateContentSize:(CGSize)contentSize
{
	if ([self.delegate respondsToSelector:@selector(scrollView:didUpdateContentSize:)]) {
		[self.delegate scrollView:self didUpdateContentSize:contentSize];
	}
}

#pragma mark [ NSKeyValueObserving ]

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
	if ((object == self) && ([keyPath isEqualToString:@"contentSize"])) {
		[self didUpdateContentSize:self.contentSize];
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

@end
