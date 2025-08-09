#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mars_logging_darwin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mars_logging_darwin'
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
  s.dependency 'OpenSSL-Universal', '~> 1.0'
  s.frameworks = 'SystemConfiguration', 'CoreTelephony', 'Foundation'
  s.libraries = 'resolv.9', 'z'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    # 'SWIFT_OBJC_BRIDGING_HEADER' => '${PODS_TARGET_SRCROOT}/Classes/MarsLogging-Bridging-Header.h',
    # 'SWIFT_OBJC_INTEROP_MODE' => 'objcxx',
    # 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
  }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'mars_logging_darwin_privacy' => ['Resources/PrivacyInfo.xcprivacy']}

  s.prepare_command = <<-EOF
  # 创建 mars Module for iOS
  rm -rf Frameworks/ios/mars.framework/Modules
  mkdir Frameworks/ios/mars.framework/Modules
  touch Frameworks/ios/mars.framework/Modules/module.modulemap
  cat <<-EOF > Frameworks/ios/mars.framework/Modules/module.modulemap
  framework module mars {
    umbrella header "xlog/xloggerbase.h"

    export *
    module * { export * }
  }
  \EOF
  # 创建 mars Module for macOS
  rm -rf Frameworks/macos/mars.framework/Modules
  mkdir Frameworks/macos/mars.framework/Modules
  touch Frameworks/macos/mars.framework/Modules/module.modulemap
  cat <<-EOF > Frameworks/macos/mars.framework/Modules/module.modulemap
  framework module mars {
    umbrella header "xlog/xloggerbase.h"

    export *
    module * { export * }
  }
  \EOF
  EOF

  s.ios.deployment_target = '12.0'
  s.ios.dependency 'Flutter'
  s.ios.vendored_frameworks = 'Frameworks/ios/*.framework'

  s.osx.deployment_target = '10.11'
  s.osx.dependency 'FlutterMacOS'
  s.osx.vendored_frameworks = 'Frameworks/macos/*.framework'
end
