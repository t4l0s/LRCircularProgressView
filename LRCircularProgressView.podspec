Pod::Spec.new do |s|
  s.name         = "LRCircularProgressView"
  s.version      = "0.0.1"
  s.summary      = "LRCircularProgressView is a simple view to display and animate progress."
  s.homepage     = "https://github.com/t4l0s/LRCircularProgressView"
  s.license      = { :type => "MIT", :file => 'LICENSE' }
  s.author       = { "Lukas Riebel" => "t4l0s@theriebel.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/t4l0s/LRCircularProgressView.git", :tag => "0.0.1" }
  s.source_files = "src/*.{h,m}"
  s.frameworks   = 'Foundation', 'UIKit'
  s.requires_arc = true
end