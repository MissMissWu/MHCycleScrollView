Pod::Spec.new do |s|

  s.name         = "MHCycleScrollView"
  s.version      = "1.0.0"
  s.summary      = "A good infinite scrollView made by CoderMikeHe"
  s.homepage     = "https://github.com/CoderMikeHe/MHCycleScrollView"
  s.license      = "MIT"
  s.authors      = {"CoderMikeHe" => "491273090@qq.com"}
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/CoderMikeHe/MHCycleScrollView.git", :tag => s.version }
  s.source_files  = "MHCycleScrollView", "MHCycleScrollView/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.dependency 'SDWebImage', '~> 3.8.1'
  s.requires_arc = true

end