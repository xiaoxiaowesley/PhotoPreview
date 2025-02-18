Pod::Spec.new do |s|
    s.name             = 'PhotoPreview'
    s.version          = '1.0.0'
    s.summary          = 'A lightweight image preview component for iOS.'
    s.homepage         = 'https://github.com/xiaoxiaowesley/PhotoPreview'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'xiaoxiaowesley' => 'xiaoxiaowesley@gmail.com' }
    s.platform         = :ios, '13.0'
  
    s.source           = { :git => 'https://github.com/xiaoxiaowesley/PhotoPreview.git', :tag => s.version.to_s } 
    s.source_files     = 'Sources/PhotoPreview/*.swift'
    s.dependency       'SDWebImage', '~> 5.20.0'
    
    # 添加 Swift 版本
    s.swift_version    = '5.0' # 根据您的项目选择合适的 Swift 版本
  end
  