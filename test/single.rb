require 'SVG/Graph/BarHorizontal'
require 'SVG/Graph/Bar'
require 'SVG/Graph/Line'
require 'SVG/Graph/Pie'


File.open( "data.txt" ) { |fin|
  title = fin.readline
  fields = fin.readline.split( /,/ )
  female_data = fin.readline.split( " " ).collect{|x| x.to_i}
  male_data = fin.readline.split( " " ).collect{|x| x.to_i}

  graph = SVG::Graph::Pie.new( {
    :width => 640,
    :height => 480,
    :fields => fields,
    :graph_title => title,
    :show_graph_title => true,
    :no_css => true,
    :expanded => true,
    :show_data_labels => true
  })
  graph.add_data( {
      :data => female_data,
      :title => "Female"
    })
  graph.add_data( {
      :data => male_data,
      :title => "Male"
    })
  puts graph.burn
}

