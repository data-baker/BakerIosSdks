#
#  Be sure to run `pod spec lint DBAudioSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "DBAudioSDK"
  spec.version      = "1.0.5"
  spec.summary      = "标贝科技语音SDK库"

  spec.description  = <<-DESC
          标贝科技语音SDK库
                   DESC

  spec.homepage     = "https://github.com/data-baker/BakerIosSdks"

  spec.license  = 'MIT'
  

  spec.author             = { "linxi" => "linxi@data-baker.com" }
 
  spec.source           = { :git => 'https://github.com/data-baker/BakerIosSdks.git', :tag => spec.version.to_s }

  # spec.source_files  = "Classes", "DBAudioSDK/Classes/DBCommonLib/*.framework"

  spec.ios.deployment_target = '9.0'

  # spec.vendored_frameworks   = 'DBAudioSDK/Classes/DBCommonLib/*.framework'
  spec.source_files = 'DBAudioSDK/Classes/DBToolKit/**/*.{h,m}'

  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' } 
 
 
  spec.subspec 'DBLongASRKit' do |longASRKit|
    # longASRKit.vendored_frameworks   = 'DBAudioSDK/Classes/DBCommonLib/*.framework'
    # longASRKit.source_files = 'DBAudioSDK/Classes/DBToolKit/**/*.{h,m}'
    longASRKit.source_files = 'DBAudioSDK/Classes/{DBLongASRKit,DBToolKit}/**/*.{h,m}'
  end

  spec.subspec 'DBShortASRKit' do |shortASRKit|
    # shortASRKit.vendored_frameworks   = 'DBAudioSDK/Classes/DBCommonLib/*.framework'
      shortASRKit.source_files = 'DBAudioSDK/Classes/{DBToolKit,DBShortASRKit}/**/*.{h,m}'
    # shortASRKit.source_files = 'DBAudioSDK/Classes/DBShortASRKit/*.{h,m}'
  end

  spec.subspec 'DBOnlineTTSKit' do |onlineTTSKit|
    # onlineTTSKit.vendored_frameworks   = 'DBAudioSDK/Classes/DBCommonLib/*.framework'
    onlineTTSKit.source_files = 'DBAudioSDK/Classes/{DBToolKit,DBOnlineTTSKit}/**/*.{h,m}'
    # onlineTTSKit.source_files = 'DBAudioSDK/Classes/DBOnlineTTSKit/*.{h,m}'
  end

  spec.subspec 'DBVoiceTransferKit' do |voiceTransferKit|
       voiceTransferKit.source_files = 'DBAudioSDK/Classes/{DBToolKit,DBVoiceTransferKit}/**/*.{h,m}'

    # voiceTransferKit.vendored_frameworks   = 'DBAudioSDK/Classes/DBCommonLib/*.framework'
    # voiceTransferKit.source_files = 'DBAudioSDK/Classes/DBVoiceTransferKit/*.{h,m}'
  end
 spec.subspec 'DBVoiceEngraverKit' do |voiceEngraverKit|
    # voiceEngraverKit.vendored_frameworks   = 'DBAudioSDK/Classes/DBCommonLib/*.framework'
    voiceEngraverKit.source_files = 'DBAudioSDK/Classes/{DBToolKit,DBVoiceEngraverKit}/**/*.{h,m}'

    # voiceEngraverKit.source_files = 'DBAudioSDK/Classes/DBVoiceEngraverKit/*.{h,m}'
  end


end
