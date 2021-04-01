# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Sweechat' do
    # Comment the next line if you don't want to use dynamic frameworks
    use_frameworks!

    # Pods for SlackersTest
    # add the Firebase pod for Google Analytics
    pod 'Firebase/Analytics'
    pod 'Firebase/Messaging'
    pod 'Firebase/Auth'
    pod 'Firebase/Firestore'
    pod 'Firebase/Storage'

    # add swift extension
    pod 'FirebaseFirestoreSwift'

    # Google sign in
    pod 'GoogleSignIn'

    # Facebook sign in
    pod 'FacebookCore'
    pod 'FacebookLogin'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if Gem::Version.new('9.0') > Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
  end
end
