Pod::Spec.new do |s|
  s.name             = "SwiftCLI"
  s.version          = "0.2"
  s.summary          = "A powerful framework than can be used to develop a CLI in Swift."

  s.homepage         = "https://github.com/jakeheis/SwiftCLI"
  
  s.license          = 'MIT'
  s.author           = { "jakeheis" => "jakeheiser1@gmail.com" }
  s.source           = { :git => "https://github.com/jakeheis/SwiftCLI.git", :tag => "#{s.version}" }

  s.platform     = :osx, '10.10'
  s.requires_arc = true

  s.source_files = 'SwiftCLI/**/*'
  
  s.dependency 'LlamaKit', '~> 0.6'
end