//
//  NMSlideshowView.m
//  NoMo
//
//  Created by Costas Harizakis on 9/25/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMSlideshowView.h"
#import "NMDynamicScrollView.h"
#import "SMPageControl.h"


@interface NMSlideshowView () <NMDynamicScrollViewDelegate, NMDynamicScrollViewDataSource>

@property (nonatomic, weak) IBOutlet NMDynamicScrollView *scrollView;
@property (nonatomic, weak) IBOutlet SMPageControl *pageControl;

- (IBAction)didChangePageControlValue:(id)sender;

- (void)updatePageControlState;
- (void)updateScrollViewStateAnimated:(BOOL)animated;

@end


@implementation NMSlideshowView

#pragma mark - [ Properties ]

- (void)setSlideImagePaths:(NSArray *)slideImagePaths
{
	if (_slideImagePaths != slideImagePaths) {
		_slideImagePaths = [slideImagePaths copy];
		
		[_scrollView reloadData];
		
		_pageControl.numberOfPages = _scrollView.numberOfPages;
		_pageControl.currentPage = _scrollView.currentPage;
	}
}

#pragma mark - [ UIView Methods ]

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self addContentSubview:[self contentViewFromNib]];

	_pageControl.indicatorMargin = 9.0;
	_pageControl.indicatorDiameter = 7.0;
	_pageControl.pageIndicatorTintColor = [UIColor colorWithRGB:0x666666];
	_pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
	_pageControl.numberOfPages = 0;
}

#pragma mark - [ Properties ]

- (NSUInteger)currentSlide
{
	return _pageControl.currentPage;
}

- (void)setCurrentSlide:(NSUInteger)currentSlide
{
	_pageControl.currentPage = currentSlide;
	_scrollView.currentPage = _pageControl.currentPage;
}

#pragma mark - [ Actions ]

- (void)didChangePageControlValue:(id)sender
{
	[self updateScrollViewStateAnimated:YES];
}

#pragma mark - [ UIScrollViewDelegate ]

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (_scrollView.isDragging) {
		[self updatePageControlState];
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	[self updatePageControlState];
}

#pragma mark - [ NMPageScrollViewDelegate ]

- (void)scrollViewWillUpdateContentLayout:(NMDynamicScrollView *)scrollView
{
	// Nothing to be done.
}

- (void)scrollViewDidUpdateContentLayout:(NMDynamicScrollView *)scrollView
{
	[self updateScrollViewStateAnimated:NO];
}

#pragma mark - [ NMPageScrollViewDataSource ]

- (NSUInteger)numberOfPages
{
	return _slideImagePaths.count;
}

- (UIView *)viewForPageAtIndex:(NSUInteger)index
{
	NSString *imagePath = [_slideImagePaths objectAtIndex:index];
	NSURL *imageURL = [NSURL URLWithString:imagePath];
	
	UIImageView *imageView = [[UIImageView alloc] init];
	[imageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:[self assetNameForIndex:index]]];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.clipsToBounds = YES;
	
	//imageView.borderColor = [UIColor whiteColor];
	//imageView.borderWidth = 2.0;
	//imageView.cornerRadius = 4.0;
	
	UIView *view = [[UIView alloc] initWithFrame:self.bounds];
	
	imageView.frame = CGRectInset(view.bounds, 30.0, 0.0);
	imageView.translatesAutoresizingMaskIntoConstraints = NO;
	
	[view addSubview:imageView];

	NSDictionary *views = NSDictionaryOfVariableBindings(imageView);
	
	[view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[imageView]-30-|" options:0 metrics:nil views:views]];
	[view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imageView]-0-|" options:0 metrics:nil views:views]];
	[view setNeedsUpdateConstraints];

	return view;
}

#pragma mark - [ Private Methods]

- (void)updatePageControlState
{
	_pageControl.currentPage = _scrollView.currentPage;
}

- (void)updateScrollViewStateAnimated:(BOOL)animated
{
	[_scrollView scrollToPageAtIndex:_pageControl.currentPage animated:animated];
}

- (NSString*)assetNameForIndex:(NSUInteger)index {
    NSString* assetName = @"slide01";
    if (index < 6) {
        assetName = [NSString stringWithFormat:@"slide0%lu", (unsigned long)index+1];
    }
    return assetName;
}

@end
