$: << File.dirname(__FILE__) + '/../lib'
require "test/unit"
require "svggraph"
require "SVG/graph/data_point"

class TestSvgGraph < Test::Unit::TestCase
  def test_bar_line_and_pie
      fields = %w(Jan Feb Mar);
      data_sales_02 = [12, 45, 21]
      [SVG::Graph::Bar, SVG::Graph::BarHorizontal, SVG::Graph::Line, SVG::Graph::Pie].each do
          |klass|
          graph = klass.new(
          :height => 500,
          :width => 300,
          :fields => fields
          )
          graph.add_data(
          :data => data_sales_02,
          :title => 'Sales 2002'
          )
          out=graph.burn
          assert(out=~/Created with SVG::Graph/)
      end
  end
end
