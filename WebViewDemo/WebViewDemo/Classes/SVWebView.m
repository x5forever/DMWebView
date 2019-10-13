
//
//  SVWebView.m
//  SVWebViewDemo
//
//  Created by x5 on 16/8/30.
//  Copyright © 2016年 Xcution. All rights reserved.
//

#import "SVWebView.h"
#import "NJKWebViewProgress.h"

//#if iOS8 以上 （本想在编译期判断iOS系统，宏定义一个bridge，如下。可是一直没有找到能在编译期判断iOS系统的宏处理，目前能解决的方式：id bridge. 从此我便深深地爱上了id指针 —— by x5）
//#define SVWebViewJSBRIDGE_TYPE WKWebViewJavascriptBridge
//#else
//#define SVWebViewJSBRIDGE_TYPE WebViewJavascriptBridge
//#endif

@interface SVWebView ()<WKNavigationDelegate,WKUIDelegate,NJKWebViewProgressDelegate> {
    struct {
        unsigned int didStartLoad           : 1;
        unsigned int didFinishLoad          : 1;
        unsigned int didFailLoad            : 1;
        unsigned int shouldStartLoad        : 1;
        unsigned int jsBridge               : 1;
    }_delegateFlags;
}
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) double estimatedProgress;
@property (nonatomic, strong) NSURLRequest *originRequest;
@property (nonatomic, strong) NSURLRequest *currentRequest;
@property (nonatomic, strong) NJKWebViewProgress *njkWebViewProgress;
@property (nonatomic, strong) id bridge;
@property (nonatomic, assign) BOOL isBlank; //v2.0.1判断_blank
@end

@implementation SVWebView
@synthesize realWebView = _realWebView;
@synthesize scalesPageToFit = _scalesPageToFit;
- (instancetype)initWithCoder:(NSCoder *)coder { if (self = [super initWithCoder:coder]) [self _initMyself]; return self;}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _initMyself];
    }
    return self;
}
- (void)_initMyself {
    [self initWKWebView];
    self.isBlank = NO;
    self.scalesPageToFit = YES;
    [self.realWebView setFrame:self.bounds];
    [self.realWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.realWebView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    [self addSubview:self.realWebView];
    [WKWebViewJavascriptBridge enableLogging];
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.realWebView];
    [self.bridge setWebViewDelegate:self];
    
}
- (void)setDelegate:(id<SVWebViewDelegate>)delegate {
    _delegate = delegate;
    _delegateFlags.didStartLoad = [_delegate respondsToSelector:@selector(webViewDidStartLoad:)];
    _delegateFlags.didFinishLoad = [_delegate respondsToSelector:@selector(webViewDidFinishLoad:)];
    _delegateFlags.didFailLoad = [_delegate respondsToSelector:@selector(webView:didFailLoadWithError:)];
    _delegateFlags.shouldStartLoad = [_delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)];
    _delegateFlags.jsBridge = [_delegate respondsToSelector:@selector(webView:jsBridge:)];
    [self registerNativeBridge:self.bridge];
}
- (void)initWKWebView {
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    WKWebViewConfiguration* configuration = [[WKWebViewConfiguration alloc] init];
    configuration.preferences = preferences;
    configuration.userContentController = [WKUserContentController new];
    
    WKWebView* webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:configuration];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    
    _realWebView = webView;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"estimatedProgress"]) {
        self.estimatedProgress = [change[NSKeyValueChangeNewKey] doubleValue];
    }else if([keyPath isEqualToString:@"title"]) {
        self.title = change[NSKeyValueChangeNewKey];
    }else {
        [self willChangeValueForKey:keyPath];
        [self didChangeValueForKey:keyPath];
    }
}

- (void)setScalesPageToFit:(BOOL)scalesPageToFit {
    _scalesPageToFit = scalesPageToFit;
    if (scalesPageToFit) {
        NSString *jScript = @"var meta = document.createElement('meta'); \
        meta.name = 'viewport'; \
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; \
        var head = document.getElementsByTagName('head')[0];\
        head.appendChild(meta);";
        WKWebView *webView = _realWebView;
        [webView evaluateJavaScript:jScript completionHandler:nil];
    }
}

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    self.estimatedProgress = progress;
}
#pragma mark - 基础方法
// 判断当前加载的url是否是WKWebView不能打开的协议类型
- (BOOL)isLoadingWKWebViewDisableScheme:(NSURL*)url
{
    BOOL retValue = NO;
    // 判断是否正在加载WKWebview不能识别的协议类型：phone numbers, email address, maps, etc.
    if ([url.scheme isEqualToString:@"tel"] || [url.scheme isEqualToString:@"sms"] || [url.scheme isEqualToString:@"mailto"]) {
        UIApplication* app = [UIApplication sharedApplication];
        if ([app canOpenURL:url]) {
            [app openURL:url];
            retValue = YES;
        }
    }
    // 下载企业包
    if ([url.absoluteString containsString:@"ms-services://"]) { //解决2.5.2
        UIApplication *app = [UIApplication sharedApplication];
        if ([app canOpenURL:url]) {
            [app openURL:url];
            retValue = YES;
        }
    }
    // 跳转到 AppStore
    if ([url.absoluteString containsString:@"apps.apple.com"] || [url.absoluteString containsString:@"itunes.apple.com"]) {
        UIApplication* app = [UIApplication sharedApplication];
        if ([app canOpenURL:url]) {
            [app openURL:url];
            retValue = YES;
        }
    }
    // Scheme 跳转
    if ([url.absoluteString hasSuffix:@"://"]) {
        UIApplication* app = [UIApplication sharedApplication];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) { // iOS9添加Scheme白名单，没有添加到白名单 canOpenURL 返回NO
            retValue = [app openURL:url];
        }else {
            if ([app canOpenURL:url]) {
                [app openURL:url];
                retValue = YES;
            }
        }
        
    }
    // _blank
    if (_isBlank){
        UIApplication* app = [UIApplication sharedApplication];
        if ([app canOpenURL:url]) {
            [app openURL:url];
            retValue = YES;
            _isBlank = NO;
        }
    }
    return retValue;
}
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    BOOL resultBOOL = [self callback_webViewShouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    BOOL isLoadingDisableScheme = [self isLoadingWKWebViewDisableScheme:navigationAction.request.URL];
    
    if(resultBOOL && !isLoadingDisableScheme){
        self.currentRequest = navigationAction.request;
        if(navigationAction.targetFrame == nil) {
            [webView loadRequest:navigationAction.request];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    }else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self callback_webViewDidStartLoad];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self callback_webViewDidFinishLoad];
}
- (void)webView:(WKWebView *) webView didFailProvisionalNavigation: (WKNavigation *) navigation withError: (NSError *) error {
    [self callback_webViewDidFailLoadWithError:error];
}
- (void)webView: (WKWebView *)webView didFailNavigation:(WKNavigation *) navigation withError: (NSError *) error {
    [self callback_webViewDidFailLoadWithError:error];
}
// 解决白屏问题
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView  {
    [webView reload];
}
#pragma mark- WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [(UIViewController *)_delegate presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [(UIViewController *)_delegate presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    [(UIViewController *)_delegate presentViewController:alertController animated:YES completion:nil];
}
// 支持window.open()
-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (navigationAction.targetFrame == nil || !navigationAction.targetFrame.isMainFrame) {
        _isBlank = YES;
    }
    return nil;
}
#pragma mark- callback SVWebView Delegate
- (void)callback_webViewDidFinishLoad { if(_delegateFlags.didFinishLoad) [self.delegate webViewDidFinishLoad:self];}
- (void)callback_webViewDidStartLoad { if(_delegateFlags.didStartLoad) [self.delegate webViewDidStartLoad:self];}
- (void)callback_webViewDidFailLoadWithError:(NSError *)error { if(_delegateFlags.didFailLoad) [self.delegate webView:self didFailLoadWithError:error];}
- (BOOL)callback_webViewShouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(NSInteger)navigationType {
    BOOL resultBOOL = YES;
    if(_delegateFlags.shouldStartLoad) {
        if(navigationType == -1) {
            navigationType = UIWebViewNavigationTypeOther;
        }
        resultBOOL = [self.delegate webView:self shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return resultBOOL;
}

#pragma mark - 基础方法
- (UIScrollView *)scrollView {
    return [(id)self.realWebView scrollView];
}

- (id)loadRequest:(NSURLRequest *)request {
    self.originRequest = request;
    self.currentRequest = request;
    return [(WKWebView*)self.realWebView loadRequest:request];
}
- (id)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    return [(WKWebView*)self.realWebView loadHTMLString:string baseURL:baseURL];
}
- (NSURLRequest *)currentRequest {
    return _currentRequest;
}
- (NSURL *)URL {
    return [(WKWebView*)self.realWebView URL];
}
- (BOOL)isLoading {
    return [self.realWebView isLoading];
}
- (BOOL)canGoBack {
    return [self.realWebView canGoBack];
}
- (BOOL)canGoForward {
    return [self.realWebView canGoForward];
}
- (WKNavigation *)goBack {
    return [(WKWebView*)self.realWebView goBack];
}
- (WKNavigation *)goForward {
    return [(WKWebView*)self.realWebView goForward];
}
- (WKNavigation *)reload {
    return [(WKWebView*)self.realWebView reload];
}
- (WKNavigation *)reloadFromOrigin {
    return [(WKWebView*)self.realWebView reloadFromOrigin];
}
- (void)stopLoading {
    [self.realWebView stopLoading];
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler {
    return [(WKWebView*)self.realWebView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString {
    __block NSString* result = nil;
    __block BOOL isExecuted = NO;
    [(WKWebView*)self.realWebView evaluateJavaScript:javaScriptString completionHandler:^(id obj, NSError *error) {
        result = obj;
        isExecuted = YES;
    }];
    
    while (isExecuted == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    return result;
}
/**
 *  添加js回调oc通知方式，适用于 iOS8 之后
 */
- (void)addScriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name {
    if ([_realWebView isKindOfClass:NSClassFromString(@"WKWebView")]) {
        [[(WKWebView *)_realWebView configuration].userContentController addScriptMessageHandler:scriptMessageHandler name:name];
    }
}

/**
 *  注销 注册过的js回调oc通知方式，适用于 iOS8 之后
 */
- (void)removeScriptMessageHandlerForName:(NSString *)name {
    if ([_realWebView isKindOfClass:NSClassFromString(@"WKWebView")]) {
        [[(WKWebView *)_realWebView configuration].userContentController removeScriptMessageHandlerForName:name];
    }
}

- (NSInteger)countOfHistory {
    return _realWebView.backForwardList.backList.count;
}
- (void)gobackWithStep:(NSInteger)step {
    if(self.canGoBack == NO)
        return;
    if(step > 0) {
        NSInteger historyCount = self.countOfHistory;
        if(step >= historyCount) {
            step = historyCount - 1;
        }
        WKWebView* webView = self.realWebView;
        WKBackForwardListItem* backItem = webView.backForwardList.backList[step];
        [webView goToBackForwardListItem:backItem];
    } else {
        [self goBack];
    }
}
#pragma mark -  如果没有找到方法 去realWebView 中调用
- (BOOL)respondsToSelector:(SEL)aSelector {
    BOOL hasResponds = [super respondsToSelector:aSelector];
    if(hasResponds == NO) {
        hasResponds = [self.delegate respondsToSelector:aSelector];
    }
    if(hasResponds == NO) {
        hasResponds = [self.realWebView respondsToSelector:aSelector];
    }
    return hasResponds;
}
- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature* methodSign = [super methodSignatureForSelector:selector];
    if(methodSign == nil) {
        if([self.realWebView respondsToSelector:selector]) {
            methodSign = [self.realWebView methodSignatureForSelector:selector];
        } else {
            methodSign = [(id)self.delegate methodSignatureForSelector:selector];
        }
    }
    return methodSign;
}
- (void)forwardInvocation:(NSInvocation*)invocation {
    if([self.realWebView respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self.realWebView];
    } else {
        [invocation invokeWithTarget:self.delegate];
    }
}
#pragma mark - dealloc
- (void)dealloc {
    WKWebView* webView = _realWebView;
    webView.UIDelegate = nil;
    webView.navigationDelegate = nil;
    [webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [webView removeObserver:self forKeyPath:@"title"];
    [_realWebView scrollView].delegate = nil;
    [_realWebView removeObserver:self forKeyPath:@"loading"];
    [(UIWebView*)_realWebView loadHTMLString:@"" baseURL:nil];
    [_realWebView stopLoading];
    [_realWebView removeFromSuperview];
    _realWebView = nil;
}
#pragma mark - registerNativeBridge
- (void)registerNativeBridge:(id )webBridge {
    if (_delegateFlags.jsBridge) [_delegate webView:self jsBridge:webBridge];
}
@end
