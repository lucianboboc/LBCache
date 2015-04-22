Pod::Spec.new do |s|

  s.name         = "LBCache"
  s.version      = "1.0.1"
  s.summary      = "LBCache image cache framework"
  s.description  = <<-DESC
                   LBCache is an asynchronous image cache framework for iOS.
                   It offers:
                   - asynchronous image download.
                   - cache support (memory and disk).
                   - option to get the local path to an image.
                   DESC

  s.homepage     = "https://github.com/lucianboboc/LBCache"
  s.license      = "MIT"
  s.author             = { "Lucian Boboc" => "info@lucianboboc.com" }
  s.social_media_url = 'http://twitter.com/lucianboboc'
  s.source       = { :git => "https://github.com/lucianboboc/LBCache.git", :tag => "1.0.0" }

  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files  = "LBCache/*.{h,m}"

end
