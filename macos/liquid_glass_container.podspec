Pod::Spec.new do |s|
  s.name             = 'liquid_glass_container'
  s.version          = '0.1.0'
  s.summary          = 'Native Liquid Glass containers for Flutter (macOS).'
  s.description      = <<-DESC
Hosts Apple's NSGlassEffectView Liquid Glass material behind Flutter content.
                       DESC
  s.homepage         = 'https://github.com/kiddo4/liquid_glass_container'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Taiwo Olanrewaju' => 'olanrewajutaiwo183@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'liquid_glass_container/Sources/liquid_glass_container/**/*'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
