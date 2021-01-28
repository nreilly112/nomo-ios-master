//
//  NMWidgetTabViewController.m
//  NoMo
//
//  Created by Marta on 23.08.2018.
//  Copyright © 2018 MiiCard. All rights reserved.
//

#import "NMWidgetTabViewController.h"
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface NMWidgetTabViewController () <UIWebViewDelegate>

@end

@implementation NMWidgetTabViewController

- (void)dealloc
{
    [_webView stopLoading];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:self.urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [_webView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonTap:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:true];
}

@end
