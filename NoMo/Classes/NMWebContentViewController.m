//
//  NMWebContentViewController.m
//  NoMo
//
//  Created by Costas Harizakis on 9/26/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMWebContentViewController.h"


@interface NMWebContentViewController () <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIView *loadingView;

@property (nonatomic, assign) NSInteger numberOfLoadTasks;

- (void)reloadIfNeeded;
- (BOOL)isLoading;
- (void)showLoading:(BOOL)show animated:(BOOL)animated;
- (void)updateStateAnimated:(BOOL)animated;

@end


@implementation NMWebContentViewController

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[_webView stopLoading];
}

#pragma mark - [ Properties ]

- (void)setLandingURL:(NSString *)landingURL
{
	if (![_landingURL isEqualToString:landingURL]) {
		_landingURL = [landingURL copy];
		[self reloadIfNeeded];
	}
}

#pragma mark - [ UIViewController ]

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_webView.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self reloadIfNeeded];
	[self updateStateAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

#pragma mark - [ UIWebViewDelegate ]

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:request.URL options:@{ } completionHandler:nil];
		return NO;
	}
	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	_numberOfLoadTasks += 1;
	
	[self updateStateAnimated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	_numberOfLoadTasks -= 1;
	
	[self updateStateAnimated:YES];

	if (!self.isLoading) {
		[self performBlockOnMainThread:^(void) {
			[self.webView.scrollView flashScrollIndicators];
		} afterDelay:0.25];
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	NSLog(@"Error: %@", error.description);
	
	_numberOfLoadTasks -= 1;
	
	[self updateStateAnimated:YES];
}

#pragma mark - [ Private Methods ]

- (void)reloadIfNeeded
{
	if ((_landingURL) && (self.isViewLoaded)) {
		NSString *landingURL = _landingURL;
		NSString *bundlePrefix = @"bundle://";
		
		if ([landingURL hasPrefix:bundlePrefix]) {
			landingURL = [landingURL stringByReplacingOccurrencesOfString:bundlePrefix withString:@"/"];
			landingURL = [landingURL stringByPrependingMainBundleResourcePath];
		}
		else {
			NSURL *baseURL = [NoMoSettings contentBaseURL];
			NSURL *contentURL = [NSURL URLWithString:landingURL relativeToURL:baseURL];
			landingURL = [contentURL absoluteString];
		}
		
		NSURL *requestURL = [NSURL URLWithString:landingURL];
		NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
		[_webView loadRequest:request];
	}
}

- (BOOL)isLoading
{
	return (0 < _numberOfLoadTasks);
}

- (void)showLoading:(BOOL)show animated:(BOOL)animated
{
	[_loadingView setHidden:!show animated:animated];
}

- (void)updateStateAnimated:(BOOL)animated
{
	[self showLoading:self.isLoading animated:animated];
}

@end
