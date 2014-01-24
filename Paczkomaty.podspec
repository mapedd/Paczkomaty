Pod::Spec.new do |s|

  s.name         = "Paczkomaty"
  s.version      = "0.0.2"
  s.summary      = "Parcel locker browser and component."

  # s.description  = <<-DESC
  #                  A longer description of Paczkomaty in Markdown format.

  #                  * Think: Why did you write this? What is the focus? What does it do?
  #                  * CocoaPods will be using this to generate tags, and improve search results.
  #                  * Try to keep it short, snappy and to the point.
  #                  * Finally, don't worry about the indent, CocoaPods strips it!
  #                  DESC

  s.homepage     = "https://github.com/mapedd/Paczkomaty"
  s.screenshots  = "https://dl.dropboxusercontent.com/u/450887/paczkomaty.png"

  s.license      = 'MIT'

  s.authors          = { "Tomek Kuzma" => "mapedd@sezamkowa.net", "Creadhoc" => "email@address.com" }
  s.social_media_url = "http://twitter.com/mapedd"

  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/mapedd/Paczkomaty.git", :tag => "0.0.2" }

  s.source_files  = 'Paczkomaty/*.{h,m}'
  s.exclude_files = 'Paczkomaty/main.m','Paczkomaty/TKAppDelegate*{h,m}'

  s.resources = "Paczkomaty/Assets/*.png"

  s.framework = 'MapKit'
  s.library   = 'sqlite3'

  s.requires_arc = true

  s.dependency 'UIView+TKGeometry', '~>0.2'
  s.dependency 'NSDate-TKExtensions', '~>0.4'
  s.dependency 'NSString+TextAndNumberValidation', '~>0.11'
  s.dependency 'AFNetworking', '~>1.3.1'
  s.dependency 'RaptureXML', '~>1.0.1'

end
