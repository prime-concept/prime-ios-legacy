def available_pods
    platform :ios, '8.0'
    inhibit_all_warnings!

	# List of libraries to  install
	pod 'RestKit', '0.24.1'
	
	# AFNetworking Extension for OAuth 2 Authentication.
	pod 'AFOAuth2Client', '~> 0.1'
	
	# Testing and Search are optional components
	pod 'ChameleonFramework', '~> 1.2'
	pod 'libPhoneNumber-iOS', '~> 0.8'
	pod 'BABFrameObservingInputAccessoryView', '~> 0.1'
	pod 'RestKit/Testing'
	pod 'RestKit/Search'
	pod 'MBProgressHUD', '~> 0.9'
	pod 'SHSPhoneComponent', '~> 2.15'
	pod 'MagicalRecord'
	pod 'SSPullToRefresh'
	pod 'CountryPicker', '~> 1.2'
	pod 'InputValidators', '~> 0.3'
	pod 'Motis', '~> 1.0'
	pod 'Toast', '~> 2.4'
	pod 'MTDates', '~> 1.0'
	pod 'CardIO', '~> 5.0'
	pod 'PureLayout'
	pod 'SocketRocket', '~> 0.4'
	pod 'JDStatusBarNotification', '~> 1.5'
	pod 'TTTAttributedLabel'
	pod 'SZTextView'
  pod 'Branch'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/Performance'
  pod 'Firebase/Crashlytics'
end

target 'PRIME' do
    available_pods
end

target 'IMPERIA' do
    available_pods
end

target 'Pond Mobile' do
    available_pods
end

target 'Raiffeisen' do
    available_pods
end

target 'PrimeConcierge' do
    available_pods
end

target 'Ginza' do
    available_pods
end

target 'Formula Kino' do
    available_pods
end

target 'Otkritie' do
    available_pods
end

target 'Platinum' do
    available_pods
end

target 'Skolkovo' do
    available_pods
end

target ‘Tinkoff’ do
    available_pods
end


target ‘PrivateBankingPRIMEClub’ do
    available_pods
end

target ‘PRIME RRClub’ do
    available_pods
end

target 'Davidoff' do
    available_pods
end

target ‘PrimeClubConcierge’ do
    available_pods
end

target ‘SiriPrime’ do
    available_pods
end

target ‘ART OF LIFE’ do
    available_pods
end

target ‘PRWidgetRaiffeisen’ do
    available_pods
end

target ‘PRWGPrimeConcierge’ do
    available_pods
end

target ‘PRWGGinza’ do
    available_pods
end

target ‘PRWGOtkritie’ do
    available_pods
end

target ‘PRWGPlatinum’ do
    available_pods
end

target ‘PRWGSkolkovo’ do
    available_pods
end

target ‘PRWGTinkoff’ do
    available_pods
end

target ‘PRWGPrivateBankingPRIMEClub’ do
  available_pods
end

target ‘PRWGRRClub’ do
  available_pods
end

target 'PRWGDavidoff' do
  available_pods
end

target ‘PRWGPCC’ do
  available_pods
end

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if target.name == "AFNetworking" || target.name == "JDStatusBarNotification" || target.name == "MBProgressHUD" || target.name == "PureLayout"
                config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
            end
        end
    end
end
