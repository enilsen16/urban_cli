# -*- ruby -*-
require "rubygems"
require "hoe"

Hoe.plugin :minitest
Hoe.plugin :git

Hoe.spec "urban_cli" do
  self.readme_file = "README.rdoc"
  self.history_file = "History.rdoc"

  license "MIT"
  developer("Erik Nilsen", "enilsen16@live.com")

  dependency 'nokogiri',  '~> 1.6.5'

  dependency 'rake',      '~> 10.4', :development
  dependency 'minitest',  '~> 5.5',    :development
end

# vim: syntax=ruby
