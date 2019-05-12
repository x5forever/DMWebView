## DMWebView
* DMWebView support UIWebView & WKWebView, also integrating with WebViewJavascriptBridge

## Function
* UIWebView seamless switching to WKWebView
* support interaction between Oc and JS by using WebViewJavascriptBridge

## Add to the Podfile
```objc 
pod 'DMWebView','~>0.1.2'
```

## How to use DMWebView
```objc
UIWebView replaced by DMWebView
```

## Notes:
##### DMWebView填过WKWebView的N多坑，如下：
1. WKWebView不支持scale的设置
2. html不弹alert
3. AppStore以及tel的跳转，openURL
4. WKWebView 不支持post请求（这个没有在demo中体现，如遇见此问题，stackOverflow有解决方案，或直接改成get请求即可）
5. [[NSURLCache sharedURLCache] removeAllCachedResponses]; WKWebView清缓存不起作用了哦。(解决方案N多，不一一列举了。譬如缓存策略采用：NSURLRequestReloadIgnoringLocalCacheData)

## Update
#### V1.0.0

1. 解决 2.5.2  itms-services://



#### V1.0.0

1. 修复无法下载企业包的bug

2. WebViewJavascriptBridge 升级到 6.0.3
``
pod 'WebViewJavascriptBridge','~>6.0.3'
``


#### V0.1.1
1. 解决 iOS 8.0 - iOS 8.2 白屏问题 

```objc
if(wkWebView && self.usingUIWebView == NO && [[[UIDevice currentDevice] systemVersion] floatValue] > 8.2) {
        [self initWKWebView];
        _usingUIWebView = NO;
    }

```
#### V0.0.4
1. WebViewJavascriptBridge 6.0.0 已解决无法与原生OC交互问题，故更新到'6.0.2'：

``
pod 'WebViewJavascriptBridge','~>6.0.2'
``

#### V0.0.3
1. 解决WebViewJavascriptBridge '5.0.8' https 请求bug,(目前6.0.0 无法与原生OC交互)更新到'5.1'：

``
pod 'WebViewJavascriptBridge','~>5.1'
``
  
