#
#  Be sure to run `pod spec lint DMWebView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "DMWebView"
  s.version      = "1.0.2"
  s.summary      = "DMWebView support UIWebView & WKWebView, also integrating with WebViewJavascriptBridge"
  s.description  = <<-DESC
    DMWebView无缝桥接UIWebView和WKWebView，iOS7及以下用UIWebView,iOS8及以上默认用WKWebView,并提供了相关的API.同时还集成了WebViewJavascriptBridge，在DMWebViewDelegate协议中能实现js与oc的交互。
    DESC
  s.homepage     = "https://github.com/x5forever/DMWebView.git"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license          = { :type => 'MIT', :file => 'LICENSE' }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "x5" => "x5forever@163.com" }
  # s.social_media_url   = "http://twitter.com/x5"


  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform     = :ios, "7.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/x5forever/DMWebView.git", :tag => 'V'+s.version.to_s }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "WebViewDemo/WebViewDemo/Classes/*.{h,m}"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.frameworks = "UIKit", "WebKit"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.requires_arc = true

  s.dependency "WebViewJavascriptBridge", "~>6.0.3"
  s.dependency "NJKWebViewProgress"

end
