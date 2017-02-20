# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Lab01' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Lab01
    pod 'Alamofire'
    pod 'AlamofireImage'
    pod 'SwiftyJSON'
    pod 'RealmSwift'
    pod 'ReachabilitySwift'
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'RxGesture'
    pod 'RxSwiftExt'
    pod 'SlideMenuControllerSwift'
    pod 'ACPDownload'
    pod 'IBAnimatable'
    pod 'RxAlamofire'
    pod 'SDWebImage'
end

post_install do |installer|
installer.pods_project.targets.each do |target|
target.build_configurations.each do |config|
config.build_settings['SWIFT_VERSION'] = '3.0'
end
end
end
