#
#  Be sure to run `pod spec lint SVWabView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "SVWabView"
  s.version      = "3.0.0"
  s.summary      = "SVWabView is package of WKWebView, and integrating with WebViewJavascriptBridge_WebKit"
  s.description  = <<-DESC
    2.0.0版本之后将不再兼容UIWebView，系统兼容iOS8.0+。
    2.4.0版本删除对UIWebView框架的引用，系统兼容iOS9.0+。
    3.0.0版本更名为：SVWabView，并新增canOpen属性。
    SVWabView是WKWebView的封装，同时还集成了WebViewJavascriptBridge，在SVWabViewDelegate协议中能实现js与oc的交互。
    DESC
  s.homepage     = "https://github.com/x5forever/DMWebView.git"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license          = { :type => 'MIT', :file => 'LICENSE' }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "x5" => "x5forever@163.com" }
  # s.social_media_url   = "http://twitter.com/x5"


  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform     = :ios, "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/x5forever/DMWebView.git", :tag => 'V'+s.version.to_s }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "WebViewDemo/WebViewDemo/Classes/*.{h,m}"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.requires_arc = true

  s.dependency 'WebViewJavascriptBridge_WebKit', '~> 7.0.1'

end
