require 'rexml/document'
require 'SVG/Graph/Graph'

module SVG
  module Graph
    class BarBase < SVG::Graph::Graph
      #   Whether to have a gap between the bars or not, default
      #   is true, set to false if you don't want gaps.
      attr_accessor :bar_gap
      #   How to stack data sets.  :overlap overlaps bars with
      #   transparent colors, :top stacks bars on top of one another,
      #   :side stacks the bars side-by-side. Defaults to :overlap.
      attr_accessor :stack


      def set_defaults 
        init_with({
          :bar_gap			        => true,
          :stack                => :overlap,
        })
      end

      def get_css
        return <<EOL
/* default fill styles for multiple datasets (probably only use a single dataset on this graph though) */
.key1,.fill1{
	fill: #ff0000;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 0.5px;	
}
.key2,.fill2{
	fill: #0000ff;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 1px;	
}
.key3,.fill3{
	fill: #00ff00;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 1px;	
}
.key4,.fill4{
	fill: #ffcc00;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 1px;	
}
.key5,.fill5{
	fill: #00ccff;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 1px;	
}
.key6,.fill6{
	fill: #ff00ff;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 1px;	
}
.key7,.fill7{
	fill: #00ffff;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 1px;	
}
.key8,.fill8{
	fill: #ffff00;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 1px;	
}
.key9,.fill9{
	fill: #cc6666;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 1px;	
}
.key10,.fill10{
	fill: #663399;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 1px;	
}
.key11,.fill11{
	fill: #339900;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 1px;	
}
.key12,.fill12{
	fill: #9966FF;
	fill-opacity: 0.5;
	stroke: none;
	stroke-width: 1px;	
}
EOL
      end
    end
  end
end
