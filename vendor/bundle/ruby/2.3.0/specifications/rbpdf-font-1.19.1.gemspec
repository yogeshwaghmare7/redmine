# -*- encoding: utf-8 -*-
# stub: rbpdf-font 1.19.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rbpdf-font"
  s.version = "1.19.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["NAITOH Jun"]
  s.date = "2017-03-29"
  s.description = "RBPDF font files."
  s.email = ["naitoh@gmail.com"]
  s.homepage = ""
  s.rdoc_options = ["--exclude", "lib/fonts/"]
  s.rubygems_version = "2.5.1"
  s.summary = "RBPDF Font."

  s.installed_by_version = "2.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.6"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<test-unit>, ["~> 3.2"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.6"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<test-unit>, ["~> 3.2"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.6"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<test-unit>, ["~> 3.2"])
  end
end
