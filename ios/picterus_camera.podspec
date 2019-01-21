#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'picterus_camera'
  s.version          = '0.0.1'
  s.summary          = 'Camera plugin by Picterus.'
  s.description      = <<-DESC
Camera plugin by Picterus.
                       DESC
  s.homepage         = 'http://picterus.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Picterus' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'OpenCV'

  s.ios.deployment_target = '8.0'
end

