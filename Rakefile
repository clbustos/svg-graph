# -*- ruby -*-
# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__)+"/lib/")

require 'rubygems'
require 'rake'
require 'rake/testtask'
$:.unshift("./lib")
require 'svggraph'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "svg-graph"

  gem.license = 'GPL'

  gem.homepage = "http://www.germane-software.com/software/SVG/SVG::Graph/"
  gem.summary = "SVG:::Graph is a pure Ruby library for generating charts, which are a type of graph where the values of one axis are not scalar."
  gem.description = %Q{Gem version of SVG:::Graph. SVG:::Graph is a pure Ruby library for generating charts, which are a type of graph where the values of one axis are not scalar. SVG::Graph has a verry similar API to the Perl library SVG::TT::Graph, and the resulting charts also look the same. This isn't surprising, because SVG::Graph started as a loose port of SVG::TT::Graph, although the internal code no longer resembles the Perl original at all.
  }

  gem.email = [
    'ser_AT_germane-software.com',
    'clbustos_AT_gmail.com',
    'liehannl_AT_gmail_DOT_com',
    'pgbossi_AT_gmail_DOT_com',
  ]
  gem.authors = [
    'Sean Russell',
    'Claudio Bustos',
    'Liehann Loots',
    'Piergiuliano Bossi',
  ]
  gem.rubyforge_project = 'ruby-statsample'

  gem.files = FileList[
    'lib/**/*.rb',
    'test/test_svg_graph.rb',
    'GPL.txt',
    'History.txt',
    'LICENSE.txt',
    'Rakefile',
    'README.txt'
  ]
  # dependencies defined in Gemfile
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
end


# vim: syntax=ruby
