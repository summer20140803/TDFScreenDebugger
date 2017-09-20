Pod::Spec.new do |s|
  s.name         = "TDFScreenDebugger"
  s.version      = "0.0.1"
  s.summary      = "Debug环境下的真机调试工具"

  s.description  = <<-DESC
  provide developer convenience when compose some api request code..
                   DESC

  s.homepage     = "git@git.2dfire-inc.com:ios/TDFScreenDebugger.git"

  s.license      = "LICENSE"
  s.author       = { "oufen" => "oufen@2dfire.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "git@git.2dfire-inc.com:ios/TDFScreenDebugger.git", tag: s.version }

s.ios.deployment_target = '8.0'
s.source_files = 'TDFScreenDebuggerExample/TDFScreenDebuggerExample/Classes/**/*.{h,m}'
s.resources =  "TDFScreenDebuggerExample/TDFScreenDebuggerExample/Resource/**/*.{png,jpg,jpeg,xcassets}"

s.dependency 'TDFAPILogger'
s.dependency 'Masonry'
s.dependency 'ReactiveObjC'
s.dependency 'ICTextView'

end
