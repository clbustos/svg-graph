$: << File.dirname(__FILE__) + '/../lib'
require 'SVG/Graph/Plot'


title = "Plot"
#data1 = []
#(rand(10)+5).times{
#  data1 << rand(20)
#  data1 << rand(20)
#}
data1 = [6.1, 11.2, 0.3, 5.4, 18.5, 7.6, 1.7, 11.8, 13.9, 9.11, 11.22, 2.33, 19.44, 0.555, 3.6666, 13.77777, 7.888888, 9.9999999]
#data2 = []
#(rand(10)+5).times{
#  data2 << rand(20)
#  data2 << rand(20)
#}
data2 = [0, 18, 8, 15, 9, 4, 18, 14, 10, 2, 11, 6, 14, 12, 15, 6, 4, 17, 2, 12]


graph = SVG::Graph::Plot.new( {
  :width => 640,
  :height => 480,
  :graph_title => title,
  :show_graph_title => true,
  :no_css => true,
  :key => true,
  :scale_x_integers => true,
  :scale_y_integers => false,
  :min_x_value => 0,
  :min_y_value => 0,
  :show_data_labels => true,
  :show_x_guidelines => true,
  :show_x_title => true,
  :x_title => "Time",
  :show_y_title => true,
  :y_title => "Ice Cream Cones",
  :y_title_text_direction => :bt,
  :show_lines => false,
  :add_popups => true,
  :round_popups => false
})
graph.add_data( 
  :data => data1,
  :title => "Dataset 1"
  )
graph.add_data( 
  :data => data2,
  :title => "Dataset 2"
  )
puts graph.burn

