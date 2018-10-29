# -*- encoding: utf-8 -*-
# stub: roadie 3.2.2 ruby lib

Gem::Specification.new do |s|
  s.name = "roadie"
  s.version = "3.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Magnus Bergmark"]
  s.date = "2017-06-13"
  s.description = "Roadie tries to make sending HTML emails a little less painful by inlining stylesheets and rewriting relative URLs for you."
  s.email = ["magnus.bergmark@gmail.com"]
  s.extra_rdoc_files = ["README.md", "Changelog.md"]
  s.files = ["Changelog.md", "README.md"]
  s.homepage = "http://github.com/Mange/roadie"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9")
  s.rubygems_version = "2.5.1"
  s.summary = "Making HTML emails comfortable for the Ruby rockstars"

  s.installed_by_version = "2.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.5"])
      s.add_runtime_dependency(%q<css_parser>, ["~> 1.4"])
      s.add_development_dependency(%q<rspec>, ["~> 3.0"])
      s.add_development_dependency(%q<rspec-collection_matchers>, ["~> 1.0"])
      s.add_development_dependency(%q<webmock>, ["~> 3.0"])
    else
      s.add_dependency(%q<nokogiri>, ["~> 1.5"])
      s.add_dependency(%q<css_parser>, ["~> 1.4"])
      s.add_dependency(%q<rspec>, ["~> 3.0"])
      s.add_dependency(%q<rspec-collection_matchers>, ["~> 1.0"])
      s.add_dependency(%q<webmock>, ["~> 3.0"])
    end
  else
    s.add_dependency(%q<nokogiri>, ["~> 1.5"])
    s.add_dependency(%q<css_parser>, ["~> 1.4"])
    s.add_dependency(%q<rspec>, ["~> 3.0"])
    s.add_dependency(%q<rspec-collection_matchers>, ["~> 1.0"])
    s.add_dependency(%q<webmock>, ["~> 3.0"])
  end
end
