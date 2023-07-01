# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "multilang-jsonb/version"

Gem::Specification.new do |s|
  s.name = 'multilang-jsonb'
  s.version = Multilang::VERSION

  s.authors = ["Arthur Meinart", "bithavoc", "bluesnotred"]
  s.description = 'Model translations for Rails backed by PostgreSQL and jsonb'
  s.licenses = ['MIT']
  s.email = 'wietse@solidarts.com'
  s.files = `git ls-files`.split($/)
  s.homepage = ""
  s.require_paths = ["lib"]
  s.summary = %q{Model translations for Rails backed by PostgreSQL and jsonb}
  s.test_files = [
    "spec/multilang_spec.rb",
    "spec/schema.rb",
    "spec/spec_helper.rb"
  ]
  s.add_dependency 'pg', '~> 1.2', '>= 1.2.3'
  s.add_dependency 'activerecord', '>= 6.0'
end

