Pod::Spec.new do |s|
  s.name         = "XGAssetPickerController"
  s.version      = "1.0.0"
  s.summary      = "XGAssetPickerController is an iOS album picker that supports mixed multi-image,multi-video selection and preview."
  s.homepage     = "https://github.com/huxinguang/XGImagePickerController"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors             = { "huxinguang" => "1259198268@qq.com" }
  s.social_media_url   = "https://blog.csdn.net/huxinguang_ios" 
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/huxinguang/XGImagePickerController.git", :tag => "#{s.version}" }
  s.source_files  = "XGAssetPickerController/**/*.{h,m}"
  s.public_header_files = "XGAssetPickerController/**/*.h"
  s.frameworks = "UIKit","Foundation","Photos","AVFoundation","QuartzCore","ImageIO", "MobileCoreServices"
  s.requires_arc = true
  s.dependency "FLAnimatedImage", "~> 1.0"

end
