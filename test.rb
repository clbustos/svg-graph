require 'SVG/Graph/BarHorizontal'
require 'SVG/Graph/Bar'
require 'SVG/Graph/Line'
require 'SVG/Graph/Pie'

File.open( "data.txt" ) { |fin|
  subtitle = fin.readline
  fields = fin.readline.split( /,/ )
  female_data = fin.readline.split( " " ).collect{|x| x.to_i}
  male_data = fin.readline.split( " " ).collect{|x| x.to_i}

  graph = SVG::Graph::Pie.new( {
      :height => 480,
      :width => 640,
      :fields => fields,
      :key => true,
      :scale_integers => true,
      :bar_gap => true,
      :stack => :side,
      :area_fill => true,
      #:stagger_x_labels => true,
      #:rotate_x_labels => true,
      #:expanded => true,
      :expand_greatest => true,
      :key_position => :right,
      :graph_title => subtitle,
      :show_graph_title => true,
      :expand_gap => 20,

      :show_data_labels => true,
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
