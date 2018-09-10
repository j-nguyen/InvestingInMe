# Uncomment the next line to define a global platform for your project
platform :ios, '11.2'

use_frameworks!

def libraries
  # Pods for InvestingInMe
  pod 'SnapKit'
  pod 'JWTDecode'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxOptional'
  pod 'RxDataSources'
  pod 'RxSwiftExt'
  pod 'MaterialComponents'
  pod 'Moya/RxSwift'
  pod 'GoogleSignIn'
  pod 'RxGesture'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'RxNuke'
  pod 'ImagePicker'
  pod 'ImageViewer'
  pod 'OneSignal', '>= 2.5.2', '< 3.0'
end

target 'InvestingInMe' do
  libraries
end

target 'InvestingInMe Staging' do
  libraries
end

target 'InvestingInMeTests' do
  inherit! :search_paths
  # Pods for testing
  pod 'Quick'
  pod 'Nimble'
  pod 'RxNimble'
end

target 'OneSignalNotificationServiceExtension' do
  pod 'OneSignal', '>= 2.5.2', '< 3.0'
end

target 'OneSignalNotificationServiceExtensionStaging' do
  pod 'OneSignal', '>= 2.5.2', '< 3.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.0'
    end
  end
end
