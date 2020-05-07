//
//  WebViewJavascriptBridge.h
//
//  Created by @LokiMeyburg on 10/15/14.
//  Copyright (c) 2014 @LokiMeyburg. All rights reserved.
//

#if (__MAC_OS_X_VERSION_MAX_ALLOWED > __MAC_10_9 || __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_1)
#define supportsWKWebView
#endif

#if defined supportsWKWebView

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridgeBase.h"
#import <WebKit/WebKit.h>

@interface WebViewJavascriptBridge : NSObject<WKNavigationDelegate, WebViewJavascriptBridgeBaseDelegate>

+ (_Nonnull instancetype)bridgeForWebView:(WKWebView* _Nonnull)webView;
+ (void)enableLogging;

- (void)registerHandler:(NSString* _Nonnull)handlerName handler:(WVJBHandler _Nullable)handler;
- (void)removeHandler:(NSString* _Nonnull)handlerName;
- (void)callHandler:(NSString* _Nonnull)handlerName;
- (void)callHandler:(NSString* _Nonnull)handlerName data:(id _Nullable)data;
- (void)callHandler:(NSString* _Nonnull)handlerName data:(id _Nullable)data responseCallback:(WVJBResponseCallback _Nullable)responseCallback;
- (void)reset;
- (void)setWebViewDelegate:(id _Nullable)webViewDelegate;
- (void)disableJavscriptAlertBoxSafetyTimeout;

@end

#endif
