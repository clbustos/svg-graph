Gem::Specification.new do |s|
  s.name = %q{svg-graph19}
  s.version = "0.6.3"
 
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sean Russell. Paolo Bosetti moved into gem and made 1.9-compatible"]
  s.date = %q{2009-12-02}
  s.description = <<-EOD
THIS VERSION IS RUBY 1.9.x COMPATIBLE! 
Gem version of SVG:::Graph. SVG:::Graph is a pure Ruby library for generating charts, which are a type of graph where the values of one axis are not scalar. 
SVG::Graph has a very similar API to the Perl library SVG::TT::Graph, and the resulting charts also look the same. This isn't surprising, because SVG::Graph started as a loose port of SVG::TT::Graph, although the internal code no longer resembles the Perl original at all.
EOD
  s.email = %q{paolo.bosetti@me.com}
  s.files = ["README.markdown", ]
  s.files << Dir["lib/SVG/Graph/*.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/pbosetti/svg-graph19}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{svg-graph19}
  s.rubygems_version = %q{1.2.0}
  s.has_rdoc = false
  s.summary = %q{SVG:::Graph is a pure Ruby library for generating charts in SVG.}
end
