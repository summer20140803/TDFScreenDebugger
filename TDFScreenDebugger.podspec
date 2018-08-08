Pod::Spec.new do |s|
  s.name         = "TDFScreenDebugger"
  s.version      = "0.0.8"
  s.summary      = "Debug环境下的真机桌面级调试工具"

  s.description  = <<-DESC
  协助真机调试，加快研发人员的工作效率
  DESC

  s.homepage     = "git@git.2dfire-inc.com:ios/TDFScreenDebugger.git"

  s.license      = "LICENSE"
  s.author       = { "oufen" => "oufen@2dfire.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "git@git.2dfire-inc.com:ios/TDFScreenDebugger.git", tag: s.version }

s.ios.deployment_target = '8.0'
s.source_files = 'Classes/**/*.{h,m,mm}'
s.resource_bundle = {
    'TDFScreenDebuggerBundle' => ['Resource/**/*.{png,jpg,jpeg,xcassets,plist,lproj}']
}
#s.public_header_files = '**/*.h'

s.dependency 'TDFAPILogger'
s.dependency 'Masonry'
s.dependency 'ReactiveObjC'
s.dependency 'ICTextView'

# ********************** ARC & MRC ********************* #
s.requires_arc = false
s.requires_arc = 'Classes/**/*.{h,m}'

end
