
//
//  SVWabView.m
//  SVWabViewDemo
//
//  Created by x5 on 16/8/30.
//  Copyright © 2016年 Xcution. All rights reserved.
//

#import "SVWabView.h"

//#if iOS8 以上 （本想在编译期判断iOS系统，宏定义一个bridge，如下。可是一直没有找到能在编译期判断iOS系统的宏处理，目前能解决的方式：id bridge. 从此我便深深地爱上了id指针 —— by x5）
//#define SVWabViewJSBRIDGE_TYPE WKWebViewJavascriptBridge
//#else
//#define SVWabViewJSBRIDGE_TYPE WebViewJavascriptBridge
//#endif

@interface SVWabView ()<WKNavigationDelegate,WKUIDelegate> {
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
@property (nonatomic, strong) id bridge;
@property (nonatomic, assign) CGPoint keyBoardPoint; //v2.0.2键盘问题
@end

@implementation SVWabView

@synthesize webView = _webView;
@synthesize scalesPageToFit = _scalesPageToFit;

- (instancetype)initWithCoder:(NSCoder *)coder { if (self = [super initWithCoder:coder]) [self initSelf]; return self;}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSelf];
    }
    return self;
}
#pragma mark - 监听处理键盘
- (void)keyBoardShow {
    CGPoint point = self.webView.scrollView.contentOffset;
    self.keyBoardPoint = point;
}
- (void)keyBoardHidden {
    self.webView.scrollView.contentOffset = self.keyBoardPoint;
}
- (void)initSelf {
    [self initWKWebView];
    self.scalesPageToFit = YES;
    self.canOpen = NO;
    // 监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHidden) name:UIKeyboardWillHideNotification object:nil];
    self.webView.frame = self.bounds;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.webView];
    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    [WebViewJavascriptBridge enableLogging];
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.bridge setWebViewDelegate:self];
    
}
#pragma mark - 以下为WKWebView相关方法
- (void)setDelegate:(id<SVWabViewDelegate>)delegate {
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
    configuration.allowsInlineMediaPlayback = YES;//v2.2.0
    configuration.userContentController = [WKUserContentController new];

    _webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:configuration];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    
    _webView.backgroundColor = [UIColor clearColor];
    _webView.opaque = NO;
    
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    
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
        
        [_webView evaluateJavaScript:jScript completionHandler:nil];
    }
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
    //v2.1.0
    NSString *subString1 = @"apps.";
    NSString *subString2 = @"itunes.";
    NSString *subString3 = @"tms-ser";
    if ([url.absoluteString containsString:[subString1 stringByAppendingString:@"apple.com"]] || [url.absoluteString containsString:[subString2 stringByAppendingString:@"apple.com"]] || [url.absoluteString containsString:[subString3 stringByAppendingString:@"vices://"]]) {
        UIApplication *app = [UIApplication sharedApplication];
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
    return retValue;
}
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    BOOL resultBOOL = [self callback_webViewShouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    BOOL isLoadingDisableScheme = [self isLoadingWKWebViewDisableScheme:navigationAction.request.URL];
    if(resultBOOL && !isLoadingDisableScheme){
        self.currentRequest = navigationAction.request;
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
        if (_canOpen && [[UIApplication sharedApplication] openURL:navigationAction.request.URL]);
        else [webView loadRequest:navigationAction.request];
    }
    return nil;
}
#pragma mark- callback SVWabView Delegate
- (void)callback_webViewDidFinishLoad { if(_delegateFlags.didFinishLoad) [self.delegate webViewDidFinishLoad:self];}
- (void)callback_webViewDidStartLoad { if(_delegateFlags.didStartLoad) [self.delegate webViewDidStartLoad:self];}
- (void)callback_webViewDidFailLoadWithError:(NSError *)error { if(_delegateFlags.didFailLoad) [self.delegate webView:self didFailLoadWithError:error];}
- (BOOL)callback_webViewShouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(WKNavigationType)navigationType {
    BOOL resultBOOL = YES;
    if(_delegateFlags.shouldStartLoad) {
        resultBOOL = [self.delegate webView:self shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return resultBOOL;
}

#pragma mark - 基础方法
- (UIScrollView *)scrollView {
    return [(id)self.webView scrollView];
}

- (id)loadRequest:(NSURLRequest *)request {
    self.originRequest = request;
    self.currentRequest = request;
    return [(WKWebView*)self.webView loadRequest:request];
}
- (id)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    return [(WKWebView*)self.webView loadHTMLString:string baseURL:baseURL];
}
- (NSURLRequest *)currentRequest {
    return _currentRequest;
}
- (NSURL *)URL {
    return [(WKWebView*)self.webView URL];
}
- (BOOL)isLoading {
    return [self.webView isLoading];
}
- (BOOL)canGoBack {
    return [self.webView canGoBack];
}
- (BOOL)canGoForward {
    return [self.webView canGoForward];
}
- (WKNavigation *)goBack {
    return [(WKWebView*)self.webView goBack];
}
- (WKNavigation *)goForward {
    return [(WKWebView*)self.webView goForward];
}
- (WKNavigation *)reload {
    return [(WKWebView*)self.webView reload];
}
- (WKNavigation *)reloadFromOrigin {
    return [(WKWebView*)self.webView reloadFromOrigin];
}
- (void)stopLoading {
    [self.webView stopLoading];
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler {
    return [(WKWebView*)self.webView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString {
    __block NSString* result = nil;
    __block BOOL isExecuted = NO;
    [(WKWebView*)self.webView evaluateJavaScript:javaScriptString completionHandler:^(id obj, NSError *error) {
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
    if ([_webView isKindOfClass:NSClassFromString(@"WKWebView")]) {
        [[(WKWebView *)_webView configuration].userContentController addScriptMessageHandler:scriptMessageHandler name:name];
    }
}

/**
 *  注销 注册过的js回调oc通知方式，适用于 iOS8 之后
 */
- (void)removeScriptMessageHandlerForName:(NSString *)name {
    if ([_webView isKindOfClass:NSClassFromString(@"WKWebView")]) {
        [[(WKWebView *)_webView configuration].userContentController removeScriptMessageHandlerForName:name];
    }
}

- (NSInteger)countOfHistory {
    return _webView.backForwardList.backList.count;
}
- (void)gobackWithStep:(NSInteger)step {
    if(self.canGoBack == NO)
        return;
    if(step > 0) {
        NSInteger historyCount = self.countOfHistory;
        if(step >= historyCount) {
            step = historyCount - 1;
        }
        WKWebView* webView = self.webView;
        WKBackForwardListItem* backItem = webView.backForwardList.backList[step];
        [webView goToBackForwardListItem:backItem];
    } else {
        [self goBack];
    }
}
#pragma mark -  如果没有找到方法 去webView 中调用
- (BOOL)respondsToSelector:(SEL)aSelector {
    BOOL hasResponds = [super respondsToSelector:aSelector];
    if(hasResponds == NO) {
        hasResponds = [self.delegate respondsToSelector:aSelector];
    }
    if(hasResponds == NO) {
        hasResponds = [self.webView respondsToSelector:aSelector];
    }
    return hasResponds;
}
- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature* methodSign = [super methodSignatureForSelector:selector];
    if(methodSign == nil) {
        if([self.webView respondsToSelector:selector]) {
            methodSign = [self.webView methodSignatureForSelector:selector];
        } else {
            methodSign = [(id)self.delegate methodSignatureForSelector:selector];
        }
    }
    return methodSign;
}
- (void)forwardInvocation:(NSInvocation*)invocation {
    if([self.webView respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self.webView];
    } else {
        [invocation invokeWithTarget:self.delegate];
    }
}
#pragma mark - dealloc
- (void)dealloc {
    _webView.UIDelegate = nil;
    _webView.navigationDelegate = nil;
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_webView removeObserver:self forKeyPath:@"title"];
    [_webView scrollView].delegate = nil;
    [_webView removeObserver:self forKeyPath:@"loading"];
    [_webView stopLoading];
    [_webView removeFromSuperview];
    _webView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark - registerNativeBridge
- (void)registerNativeBridge:(id )webBridge {
    if (_delegateFlags.jsBridge) [_delegate webView:self jsBridge:webBridge];
}
@end
