//
//  ViewController2.m
//  WebViewDemo
//
//  Created by x5 on 2016/10/7.
//  Copyright © 2016年 x5. All rights reserved.
//

#import "ViewController2.h"
#import "SVWebView.h"

// method key of JSBridge
static NSString *const kJSBridgeJsCallIOS = @"jsCallIOS";

@interface ViewController2 ()<SVWebViewDelegate>
@property (strong, nonatomic)id bridge;
@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SVWebView *webView = [[SVWebView alloc] initWithFrame:self.view.bounds];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"js_iOS" ofType:@"html"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL fileURLWithPath:[self pathForWKWebViewSandboxBugWithOriginalPath:filePath]]];
    [webView loadRequest:request];
    webView.delegate = self;
    [self.view addSubview:webView];
    
    UIButton *button = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(CGRectGetMidX(self.view.frame)-50, CGRectGetMidY(self.view.frame)-25, 100, 50);
        [btn setTitle:@"oc_call_js" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor lightGrayColor];
        [btn addTarget:self action:@selector(callJS) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:button];
}
/* 在iOS9之前版本，WKWebView用loadRequest加载本地的html文件的时候会出现如下的警告
 
   Could not create a sandbox extension for '/'
 
   原因是WKWebView是不允许通过loadRequest的方法来加载本地根目录的HTML文件。
   方法解决:先将本地的html文件保存到沙盒的temp文件夹，然后从temp文件夹将html文件取出再使用
 */
- (NSString *)pathForWKWebViewSandboxBugWithOriginalPath:(NSString *)filePath
{
    NSString *newPath = filePath;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 9.0) {
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"www"];
        NSError *error = nil;
        
        if (![manager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Could not create www directory. Error: %@", error);
            
            return nil;
        }
        
        newPath = [tempPath stringByAppendingPathComponent:filePath.lastPathComponent];
        
        if (![manager fileExistsAtPath:newPath]) {
            if (![manager copyItemAtPath:filePath toPath:newPath error:&error]) {
                NSLog(@"Couldn't copy file to /tmp/www. Error: %@", error);
                return nil;
            }
        }
    }
    return newPath;
}
- (void)callJS {
    if (self.bridge) [_bridge callHandler:@"iOSCallJS" data:@{@"content":@"这是oc调js"}];
}
#pragma mark - SVWebViewDelegate
- (void)webView:(SVWebView *)webView jsBridge:(id)bridge {
    
    // get bridge for oc call js (method of callJS need current bridge)
    self.bridge = bridge;
    
    // register handler for js call oc
    [bridge registerHandler:kJSBridgeJsCallIOS handler:^(id data, WVJBResponseCallback responseCallback) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:data[@"content"] message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }];
}

@end
