#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mars_logging.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mars_logging'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'mars_logging_privacy' => ['Resources/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'
  s.dependency 'OpenSSL-Universal', '~> 1.0'
  s.frameworks = 'SystemConfiguration', 'CoreTelephony', 'Foundation'
  s.libraries = 'resolv.9', 'z'
  # s.libraries = 'resolv.9', 'z', 'ssl', 'crypto'
  s.vendored_frameworks = 'Frameworks/*.framework'
  # s.prepare_command = <<-EOF
  #   # 创建 mars Module
  #   rm -rf Frameworks/mars.framework/Modules
  #   mkdir Frameworks/mars.framework/Modules
  #   touch Frameworks/mars.framework/Modules/module.modulemap
  #   cat <<-EOF > Frameworks/mars.framework/Modules/module.modulemap
  #   framework module mars {
  #     umbrella header "xlog/xlogger_interface.h"

  #     export *
  #     module * { export * }
  #   }
  # \EOF
  # EOF

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES',
    # 'SWIFT_OBJC_BRIDGING_HEADER' => '${PODS_TARGET_SRCROOT}/Classes/MarsLogging-Bridging-Header.h'
    # 'SWIFT_OBJC_INTEROP_MODE' => 'objcxx'
  }
  s.swift_version = '5.0'
end
