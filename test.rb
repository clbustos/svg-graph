require 'SVG/Graph/BarHorizontal'

File.open( "data.txt" ) { |fin|
  subtitle = fin.readline
  fields = fin.readline.split( /,/ )
  female_data = fin.readline.split( " " ).collect{|x| x.to_i}
  male_data = fin.readline.split( " " ).collect{|x| x.to_i}

  graph = SVG::Graph::BarHorizontal.new( {
      :height => 480,
      :width => 640,
      :fields => fields,
      :key => true,
      :scale_integers => true,
      :bar_gap => true,
      :stack => :side,
      #:stagger_x_labels => true,
      #:key_position => :bottom,
      :graph_title => subtitle,
      :show_graph_title => true
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
