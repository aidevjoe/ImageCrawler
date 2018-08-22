# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'CrawlerExtension' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  # Yep.
  inhibit_all_warnings!

  # Pods for CrawlerExtension
  pod 'KingfisherWebP'
  pod 'ATGMediaBrowser'

end

target 'ImageCrawler' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ImageCrawler
  pod 'Reveal-SDK', '~> 14', :configurations => ['Debug']

  target 'ImageCrawlerTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ImageCrawlerUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
