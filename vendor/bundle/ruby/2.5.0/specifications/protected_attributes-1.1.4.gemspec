# -*- encoding: utf-8 -*-
# stub: protected_attributes 1.1.4 ruby lib

Gem::Specification.new do |s|
  s.name = "protected_attributes".freeze
  s.version = "1.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.date = "2017-05-04"
  s.description = "Protect attributes from mass assignment".freeze
  s.email = ["david@loudthinking.com".freeze]
  s.homepage = "https://github.com/rails/protected_attributes".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Protect attributes from mass assignment in Active Record models".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activemodel>.freeze, ["< 5.0", ">= 4.0.1"])
      s.add_development_dependency(%q<activerecord>.freeze, ["< 5.0", ">= 4.0.1"])
      s.add_development_dependency(%q<actionpack>.freeze, ["< 5.0", ">= 4.0.1"])
      s.add_development_dependency(%q<railties>.freeze, ["< 5.0", ">= 4.0.1"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
      s.add_development_dependency(%q<mocha>.freeze, [">= 0"])
    else
      s.add_dependency(%q<activemodel>.freeze, ["< 5.0", ">= 4.0.1"])
      s.add_dependency(%q<activerecord>.freeze, ["< 5.0", ">= 4.0.1"])
      s.add_dependency(%q<actionpack>.freeze, ["< 5.0", ">= 4.0.1"])
      s.add_dependency(%q<railties>.freeze, ["< 5.0", ">= 4.0.1"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
      s.add_dependency(%q<mocha>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<activemodel>.freeze, ["< 5.0", ">= 4.0.1"])
    s.add_dependency(%q<activerecord>.freeze, ["< 5.0", ">= 4.0.1"])
    s.add_dependency(%q<actionpack>.freeze, ["< 5.0", ">= 4.0.1"])
    s.add_dependency(%q<railties>.freeze, ["< 5.0", ">= 4.0.1"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
    s.add_dependency(%q<mocha>.freeze, [">= 0"])
  end
end
