 Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '11.0'
s.name = "VFantasyGlobal"
s.summary = "VFantasyGlobal lets a user select an ice cream flavor."
s.requires_arc = true

# 2
s.version = "0.1.0"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "Longnh" => "longnh264@gmail.com" }

# 5 - Replace this URL with your own GitHub page's URL (from the address bar)
s.homepage = "https://github.com/longnh2604/VFantasySDK.git"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/longnh2604/VFantasySDK.git",
             :tag => "#{s.version}" }

# 7
s.framework = "UIKit"
s.dependency 'SwiftDate'
s.dependency 'MZFormSheetPresentationController'
s.dependency 'SDWebImage'
s.dependency 'Alamofire'
s.dependency 'MBProgressHUD'
s.dependency 'PureLayout'
s.dependency 'HMSegmentedControl'
s.dependency 'ALCameraViewController'
s.dependency 'SMPageControl'

# 8
s.source_files = "VFantasyGlobal/**/*"

# 9
s.resources = "VFantasyGlobal/**/*"

# 10
s.swift_version = "5.0"

s.subspec 'XCFrameworkPod' do |xcframework|
  xcframework.vendored_frameworks = 'archives/VFantasyGlobal.xcframework'
end

end

