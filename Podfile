# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

def shared
    
  # Yep.
  inhibit_all_warnings!
  
  pod 'KingfisherWebP'
  pod 'ATGMediaBrowser'
end



target 'ImageCrawler' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ImageCrawler
  shared
  pod 'Reveal-SDK', '~> 14', :configurations => ['Debug']

end

target 'CrawlerExtension' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    
    shared
end
