Pod::Spec.new do |s|
  s.name         = 'TDFScreenDebugger'
  s.version      = '1.0.0'
  s.summary      = 'a built-in debugging tools for ios devices'

  s.description  = <<-DESC
  a built-in debugging tools for ios devices to help developers debug devices and accelerate the productivity of enterprise-level applications..
  DESC

  s.homepage     = 'https://github.com/summer20140803/TDFScreenDebugger'
  s.social_media_url = 'https://summer20140803.github.io/2018/05/20/iOS%E7%9C%9F%E6%9C%BA%E6%A1%8C%E9%9D%A2%E7%BA%A7%E8%B0%83%E8%AF%95%E5%B7%A5%E5%85%B7/'

  s.license      = 'LICENSE'
  s.author       = { '开不了口的猫' => 'summer20140803@gmail.com' }
  s.source       = { :git => 'https://github.com/summer20140803/TDFScreenDebugger.git', tag: s.version }

s.ios.deployment_target = '9.0'
s.source_files = 'Classes/**/*.{h,m,mm}'
s.resource_bundle = {
    'TDFScreenDebuggerBundle' => ['Resource/**/*.{png,jpg,jpeg,xcassets,plist,lproj}']
}

s.dependency 'TDFAPILogger'
s.dependency 'Masonry'
s.dependency 'ReactiveObjC'
s.dependency 'ICTextView'

s.requires_arc = false
s.requires_arc = 'Classes/**/*.{h,m}'

end
