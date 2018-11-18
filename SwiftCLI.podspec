Pod::Spec.new do |s|

  s.name         = "SwiftCLI"
  s.version      = "5.2.1"
  s.summary      = "A powerful framework that can be used to develop a CLI in Swift"

  s.description  = <<-DESC
  A powerful framework that can be used to develop a CLI, from the simplest to the most complex, in Swift.
                   DESC

  s.homepage     = "https://github.com/jakeheis/SwiftCLI"
  s.license      = "MIT"
  s.author             = { "Jake Heiser" => "email@address.com" }
  s.source       = { :git => "https://github.com/jakeheis/SwiftCLI.git", :tag => "#{s.version}" }

  s.platform     = :osx
  s.osx.deployment_target = "10.9"

  s.source_files  = "Sources", "Sources/**/*.{swift}"

  s.swift_version = "4.2.1"

end
