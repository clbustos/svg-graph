require 'SVG/Graph/BarHorizontal'
require 'SVG/Graph/Bar'
require 'SVG/Graph/Line'
require 'SVG/Graph/Pie'

def gen klass, args, title, fields, female_data, male_data
  args[ :width ] = 640
  args[ :height ] = 480
  #args[ :compress ] = true
  args[ :fields ] = fields
  args[ :graph_title ] = title
  args[ :show_graph_title ] = true
  args[ :no_css ] = true
  graph = klass.new( args )
  graph.add_data( {
      :data => female_data,
      :title => "Female"
    })
  graph.add_data( {
      :data => male_data,
      :title => "Male"
    })
  return graph.burn
end

File.open( "data.txt" ) { |fin|
  title = fin.readline
  fields = fin.readline.split( /,/ )
  female_data = fin.readline.split( " " ).collect{|x| x.to_i}
  male_data = fin.readline.split( " " ).collect{|x| x.to_i}

  for file, klass, args in [
    [ "bar", SVG::Graph::Bar,
      { :scale_integers => true, :stack => :side } ],
    [ "barhorizontal",SVG::Graph::BarHorizontal,
      {:scale_integers=> true,:stack=>:side} ],
    [ "line", SVG::Graph::Line, 
      { :scale_integers => true, :area_fill => true, } ],
    [ "pie", SVG::Graph::Pie, 
      { :expand_greatest => true, :show_data_labels => true,} ],
    ]
    File.open("#{file}.svg", "w") {|fout| 
      fout.print( gen(klass, args, title, fields, female_data, male_data ) )
    }
  end
}

