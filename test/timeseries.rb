require 'SVG/Graph/TimeSeries'


title = "Plot"
#data1 = []
#(rand(10)+5).times{
#  data1 << rand(20)
#  data1 << rand(20)
#}
data1 = ["6/17/72", 11, "1/11/72", 7, "4/13/04 17:31", 11, "9/11/01", 9, "9/1/85", 2, "9/1/88", 1, "1/15/95", 13]
#data2 = []
#(rand(10)+5).times{
#  data2 << rand(20)
#  data2 << rand(20)
#}
data2 = ["8/1/73", 18, "3/1/77", 15, "10/1/98", 4, "5/1/02", 14, "3/1/95", 6, "8/1/91", 12, "12/1/87", 6, "5/1/84", 17, "10/1/80", 12]


graph = SVG::Graph::TimeSeries.new( {
  :width => 640,
  :height => 480,
  :graph_title => title,
  :show_graph_title => true,
  :no_css => true,
  :key => true,
  :scale_x_integers => true,
  :scale_y_integers => true,
  :min_x_value => 0,
  :min_y_value => 0,
  :show_data_labels => true,
  :show_x_guidelines => true,
  :show_x_title => true,
  :x_title => "Time",
  :show_y_title => true,
  :y_title => "Ice Cream Cones",
  :y_title_text_direction => :bt,
  :stagger_x_labels => true,
  :x_label_format => "%m/%d/%y",
  :add_popups => true,
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

