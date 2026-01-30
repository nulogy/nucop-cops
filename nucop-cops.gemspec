lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "nucop/version"

Gem::Specification.new do |spec|
  spec.name = "nucop-cops"
  spec.version = Nucop::VERSION
  spec.authors = ["Jason Cheong-Kee-You", "Jason Schweier"]
  spec.email = ["jasons@nulogy.com"]
  spec.summary = "Custom RuboCop cops for Nulogy's Ruby projects."
  spec.licenses = ["MIT"]
  spec.homepage = "https://rubygems.org/gems/nucop-cops"

  spec.metadata = {
    "homepage_uri" => "https://github.com/nulogy/nucop-cops",
    "changelog_uri" => "https://github.com/nulogy/nucop-cops/blob/master/CHANGELOG.md",
    "bug_tracker_uri" => "https://github.com/nulogy/nucop-cops/issues",
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir["lib/**/*"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 3.4"

  spec.add_dependency "rubocop", "~> 1.66"

  spec.add_development_dependency "rake", "~> 13.2"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "rubocop-rspec", "~> 3.0"
end
