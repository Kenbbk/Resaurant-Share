# Uncomment the next line to define a global platform for your project
# platform :ios, '15.0'

target 'MapProject' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MapProject


  pod 'GooglePlaces', '8.0.0'
    pod 'NMapsMap'
  pod 'SnapKit'
pod 'FirebaseAuth'
pod 'FirebaseFirestore'
post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end

end
