//
//  ViewController2.m
//  WebViewDemo
//
//  Created by x5 on 2016/10/7.
//  Copyright © 2016年 x5. All rights reserved.
//

#import "ViewController2.h"
#import "DMWebView.h"

// method key of JSBridge
static NSString *const kJSBridgeJsCallIOS = @"jsCallIOS";

@interface ViewController2 ()<DMWebViewDelegate>
@property (strong, nonatomic)id bridge;
@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DMWebView *webView = [[DMWebView alloc] initWithFrame:self.view.bounds];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"js_iOS" ofType:@"html"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL fileURLWithPath:filePath]];
    [webView loadRequest:request];
    webView.delegate = self;
    [self.view addSubview:webView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(CGRectGetMidX(self.view.frame)-40, CGRectGetMidY(self.view.frame)-25, 80, 50);
    [btn setTitle:@"ocCallJS" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    btn.backgroundColor = [UIColor lightGrayColor];
    [btn addTarget:self action:@selector(callJS) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
- (void)callJS {
    if (self.bridge) [_bridge callHandler:@"iOSCallJS" data:@{@"content":@"这是oc调js"}];
}
#pragma mark - DMWebViewDelegate
- (void)webView:(DMWebView *)webView jsBridge:(id)bridge {
    
    // get bridge for oc call js (method of callJS need current bridge)
    self.bridge = bridge;
    
    // register handler for js call oc
    [bridge registerHandler:kJSBridgeJsCallIOS handler:^(id data, WVJBResponseCallback responseCallback) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:data[@"content"] message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }];
}

@end
