require 'SVG/Graph/Schedule'


title = "Billy's Schedule"
data1 = [
  "History 107", "5/19/04", "6/30/04",
  "Algebra 011", "6/2/04", "8/11/04",
  "Psychology 101", "6/28/04", "8/9/04",
  "Acting 105", "7/7/04", "8/16/04"
  ]

graph = SVG::Graph::Schedule.new( {
  :width => 640,
  :height => 480,
  :graph_title => title,
  :show_graph_title => true,
  :no_css => true,
  :key => false,
  :scale_x_integers => true,
  :scale_y_integers => true,
  :show_data_labels => true,
  :show_y_guidelines => false,
  :show_x_guidelines => true,
  :show_x_title => true,
  :x_title => "Time",
  :show_y_title => false,
  :rotate_y_labels => true,
  :stagger_y_labels => true,
  :stagger_x_labels => true,
  :x_label_format => "%m/%d",
  :timescale_divisions => "1 weeks",
  :add_popups => true,
  :popup_format => "%m/%d/%y",
  :area_fill => true,
  :min_y_value => 0,
})

graph.add_data( 
  :data => data1,
  :title => "Data"
  )

puts graph.burn

