//
//  ViewController.m
//  WebViewDemo
//
//  Created by x5 on 2016/9/28.
//  Copyright © 2016年 x5. All rights reserved.
//

#import "ViewController.h"
#import "SVWabView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SVWabView *webView = [[SVWabView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-44)];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    
}


@end
