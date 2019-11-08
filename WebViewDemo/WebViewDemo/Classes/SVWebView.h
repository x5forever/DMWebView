//
//  SVWebView.h
//  SVWebViewDemo
//
//  Created by x5 on 16/8/30.
//  Copyright © 2016年 Xcution. All rights reserved.
//  
//  V2.2.0


#import <WebKit/WKScriptMessageHandler.h>
#import "WKWebViewJavascriptBridge.h"
#import "WebViewJavascriptBridge.h"

@class SVWebView;
@protocol SVWebViewDelegate <NSObject>
@optional

- (void)webViewDidStartLoad:(SVWebView *)webView;
- (void)webViewDidFinishLoad:(SVWebView *)webView;
- (void)webView:(SVWebView *)webView didFailLoadWithError:(NSError *)error;
- (BOOL)webView:(SVWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webView:(SVWebView *)webView jsBridge:(id)bridge;
@end

@interface SVWebView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

@property(weak,nonatomic)id<SVWebViewDelegate> delegate;

// 内部使用的webView
@property (nonatomic, readonly) WKWebView *webView;

// 预估网页加载进度
@property (nonatomic, readonly) double estimatedProgress;

@property (nonatomic, readonly) NSURLRequest *originRequest;

/**
 *  添加js回调oc通知方式，适用于 iOS8 之后
 */
- (void)addScriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name;
/**
 *  注销 注册过的js回调oc通知方式，适用于 iOS8 之后
 */
- (void)removeScriptMessageHandlerForName:(NSString *)name;

// back 层数
- (NSInteger)countOfHistory;
- (void)gobackWithStep:(NSInteger)step;

// UI 或者 WK 的API
@property (nonatomic, readonly) UIScrollView *scrollView;

- (id)loadRequest:(NSURLRequest *)request;
- (id)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly) NSURLRequest *currentRequest;
@property (nonatomic, readonly) NSURL *URL;

@property (nonatomic, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, readonly) BOOL canGoBack;
@property (nonatomic, readonly) BOOL canGoForward;

- (WKNavigation *)goBack;
- (WKNavigation *)goForward;
- (WKNavigation *)reload;
- (WKNavigation *)reloadFromOrigin;
- (void)stopLoading;

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler;
// 不建议使用这个办法  因为会在内部等待webView 的执行结果
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString __deprecated_msg("Please use 'evaluateJavaScript:completionHandler:' instead");
// 是否根据视图大小来缩放页面 (by x5：该功能特意设为只读模式，不再提供给外部使用，且统一设为YES)
@property (nonatomic, readonly) BOOL scalesPageToFit;

@end
