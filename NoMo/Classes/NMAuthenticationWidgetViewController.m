//
//  NMAuthenticationWidgetViewController.m
//  NoMo
//
//  Created by Costas Harizakis on 9/28/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMAuthenticationWidgetViewController.h"
#import "DirectIDSettings.h"
#import "NMWidgetTabViewController.h"

@import WebKit;


@interface NMAuthenticationWidgetViewController () <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, assign) NSInteger numberOfLoadTasks;
@property (nonatomic, assign) NSString *authorizationAddress;
@property (nonatomic, assign) NMWidgetTabViewController * widgetTabController;

@end


@implementation NMAuthenticationWidgetViewController

#pragma mark - [ Finalizer ]

- (void)dealloc
{
    [self unregisterObservers];
	[_webView stopLoading];
}

#pragma mark - [ Private Methods ]

- (void)loadWithWidgetUrl:(NSString *)widgetUrl
{
    [self registerObservers];
    [self setUpWebView];
    
    NSURL *widgetBaseURL = [NSURL URLWithString:widgetUrl];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:widgetBaseURL];
    
    [_webView loadRequest:requestObj];
}

- (void)cancelLoad
{
	[_webView stopLoading];
	[_webView loadHTMLString:@"" baseURL:nil];
}

- (BOOL)isLoading
{
	return (0 < _numberOfLoadTasks);
}

#pragma mark - [ Events ]

- (void)didComplete
{
    [self dismissWidgetTab];
	if ([_delegate respondsToSelector:@selector(authenticationWidgetViewControllerDidComplete:)]) {
		[_delegate authenticationWidgetViewControllerDidComplete:self];
	}
}

- (void)didFailLoadWithError:(NSError *)error
{
	NSLog(@"[DirectID] [Widget failed (Error: %@).", error.description);
	
	if ([_delegate respondsToSelector:@selector(authenticationWidgetViewController:didFailWithError:)]) {
		[_delegate authenticationWidgetViewController:self didFailWithError:error];
	}
}

- (void)didStartLoad
{
	if ([_delegate respondsToSelector:@selector(authenticationWidgetViewControllerDidStartLoad:)]) {
		[_delegate authenticationWidgetViewControllerDidStartLoad:self];
	}
}

- (void)didStopLoad
{
	if ([_delegate respondsToSelector:@selector(authenticationWidgetViewControllerDidStopLoad:)]) {
		[_delegate authenticationWidgetViewControllerDidStopLoad:self];
	}
}

- (void)didInitialize
{
	if ([_delegate respondsToSelector:@selector(authenticationWidgetViewControllerDidInitialize:)]) {
		[_delegate authenticationWidgetViewControllerDidInitialize:self];
	}
}

#pragma mark - [ WKWebViewDelegate Methods ]

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *requestURL = navigationAction.request.URL;
    
    if ([[requestURL absoluteString]hasPrefix:[NoMoSettings widgetRedirectURL]]) {
        if ([[requestURL absoluteString]containsString:@"state=success"]) {
            //DirectID Connect journey is complete
            [self didComplete];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        } else if ([[requestURL absoluteString]containsString:@"state=error"]) {
            //DirectID Connect journey is complete with error
            [self didFailLoadWithError:[NSError errorWithDomain:@"Widget" code:-2 userInfo:nil]];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    if (_numberOfLoadTasks == 0) {
        [self didStartLoad];
    }
    
    _numberOfLoadTasks += 1;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    _numberOfLoadTasks -= 1;
    
    [self didInitialize];
    
    if (_numberOfLoadTasks == 0) {
        [self didStopLoad];
    }
}

- (void)didFailWithError:(NSError *)error
{
    _numberOfLoadTasks -= 1;
    
    if (_numberOfLoadTasks == 0) {
        [self didStopLoad];
    }
    
    if (error.code == NSURLErrorCancelled
        || error.code == 101) {
        return;
    }
    
    [self didFailLoadWithError:error];
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{ } completionHandler:nil];
    return nil;
    
}
#pragma mark - [ Helpers ]

-(void)dismissWidgetTab
{
    if (self.widgetTabController != nil) {
        [self.navigationController popViewControllerAnimated:true];
    }
}

-(void)setUpWebView
{
    WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc] init];
    
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:webViewConfiguration];
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;

    [self.view addSubview:_webView];
}


- (void)registerObservers
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(handleBackFromExternalWeb:) name:@"com.nomo.urlscheme" object:nil];
}

- (void)unregisterObservers
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"com.nomo.urlscheme" object:nil];
        
}

- (void)handleBackFromExternalWeb:(NSNotification *)notification {
    NSString *externalURL = [notification object];
    if (externalURL == nil) {
        return;
    }
    if ([externalURL containsString:@"state=success"]) {
        //DirectID Connect journey is complete
        [self didComplete];
        return;
    } else if ([externalURL containsString:@"state=error"]) {
        //DirectID Connect journey is complete with error
        [self didFailLoadWithError:[NSError errorWithDomain:@"Widget external" code:-2 userInfo:nil]];
        return;
    }
}
@end

