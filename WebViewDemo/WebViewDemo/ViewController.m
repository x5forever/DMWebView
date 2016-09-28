//
//  ViewController.m
//  WebViewDemo
//
//  Created by x5 on 2016/9/28.
//  Copyright © 2016年 x5. All rights reserved.
//

#import "ViewController.h"
#import "DMWebView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DMWebView *webView = [[DMWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    [self.view addSubview:webView];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    [webView loadRequest:request];
}


@end
