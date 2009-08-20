require "test/unit"
require "svggraph"

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
  def test_plot
	  
	  projection = [
         6, 11,    0, 5,   18, 7,   1, 11,   13, 9,   1, 2,   19, 0,   3, 13,
         7, 9 
       ]
       actual = [
         0, 18,    8, 15,    9, 4,   18, 14,   10, 2,   11, 6,  14, 12,   
         15, 6,   4, 17,   2, 12
       ]
       
       graph = SVG::Graph::Plot.new({
       	:height => 500,
        	:width => 300,
         :key => true,
         :scale_x_integers => true,
         :scale_y_integerrs => true,
       })
       
       graph.add_data({
       	:data => projection, 
     	  :title => 'Projected',
       })
     
       graph.add_data({
       	:data => actual,
     	  :title => 'Actual',
       })
       
       out=graph.burn()
       assert(out=~/Created with SVG::Graph/)
  end
end
