#!/usr/bin/env rake
require 'rake/testtask'
require File.expand_path('../lib/shmidi/version.rb', __FILE__)

task :build do
  system('gem build shmidi.gemspec')
end

task :install => :build do
  system('gem uninstall -y shmidi')
  system("gem install ./shmidi-#{Shmidi::VERSION}.gem")
end

task :default => :build
