require 'SVG/Graph/Graph'

module SVG
  module Graph
    # = SVG::TT::Graph::Line 
    #
    # == @ANT_VERSION@
    #
    # === Create presentation quality SVG line graphs easily
    # 
    # = Synopsis
    # 
    #   require 'SVG/Graph/Line'
    # 
    #   fields = %w(Jan Feb Mar);
    #   data_sales_02 = %w(12 45 21);
    #   data_sales_03 = %w(15 30 40);
    #   
    #   graph = SVG::Graph::Line.new({
    #   	:height => 500,
    #    	:width => 300,
    # 	  :fields => fields,
    #   })
    #   
    #   graph.add_data({
    #   	:data => data_sales_02,
    # 	  :title => 'Sales 2002',
    #   })
    # 
    #   graph.add_data({
    #   	:data => data_sales_03,
    # 	  :title => 'Sales 2003',
    #   })
    #   
    #   print "Content-type: image/svg+xml\r\n\r\n";
    #   print graph.burn();
    # 
    # = Description
    # 
    # This object aims to allow you to easily create high quality
    # SVG line graphs. You can either use the default style sheet
    # or supply your own. Either way there are many options which can
    # be configured to give you control over how the graph is
    # generated - with or without a key, data elements at each point,
    # title, subtitle etc.
    # 
    # = Notes
    # 
    # The default stylesheet handles upto 10 data sets, if you
    # use more you must create your own stylesheet and add the
    # additional settings for the extra data sets. You will know
    # if you go over 10 data sets as they will have no style and
    # be in black.
    # 
    # = See also
    # 
    # * SVG::Graph::Graph
    # * SVG::Graph::BarHorizontal
    # * SVG::Graph::BarLine
    # * SVG::Graph::Bar
    # * SVG::Graph::Pie
    # * SVG::Graph::TimeSeries
    class Line < SVG::Graph::Graph
      #    Show a small circle on the graph where the line
      #    goes from one point to the next.
      attr_accessor :show_data_points
      #    Accumulates each data set. (i.e. Each point increased by sum of 
      #   all previous series at same point). Default is 0, set to '1' to show.
      attr_accessor :stacked
      attr_accessor :area_fill

      #   require 'SVG/Graph/Line'
      #   
      #   # Field names along the X axis
      #   fields = %w(Jan Feb Mar);
      #   
      #   graph = SVG::Graph::Line.new({
      #     # Required
      #     :fields => fields,
      #   
      #     # Optional - defaults shown
      #     :height            => '500',
      #     :width             => '300',
      #     'show_data_points: => true,
      #     :show_data_values  => true,
      #     :stacked           => false,
      # 
      #     :min_scale_value   => false,
      #     :area_fill         => false,
      #     :show_x_labels     => true,
      #     :stagger_x_labels  => false,
      #     :rotate_x_labels   => false,
      #     :show_y_labels     => true,
      #     :scale_integers    => false,
      #     :scale_divisions   => 20,
      # 	
      #     :show_x_title      => false,
      #     :x_title           => 'X Field names',
      # 
      #     :show_y_title      => false,
      #     :y_title_text_direction => :bt,
      #     :y_title           => 'Y Scale',
      # 
      #     :show_graph_title      => false,
      #     :graph_title           => 'Graph Title',
      #     :show_graph_subtitle   => false,
      #     :graph_subtitle        => 'Graph Sub Title',
      #     :key                   => false,
      #     :key_position          => :right,
      # 
      #     # Optional - defaults to using internal stylesheet
      #     :style_sheet       => '/includes/graph.css',
      #   });
      # 
      # The constructor takes a hash reference, fields (the names for each
      # field on the X axis) MUST be set, all other values are defaulted to 
      # those shown above - with the exception of style_sheet which defaults
      # to using the internal style sheet.
      def initialize config
        super
      end

      def set_defaults
	      init_with({
          :show_data_points   => true,
          :show_data_values   => true,
          :stacked            => false,
          :area_fill          => false,
        })
      end

      def get_x_labels
        @config[:fields]
      end

      def calculate_left_margin
        super
        label_left = @config[:fields][0].length / 2 * font_size * 0.6
        @border_left = label_left if label_left > @border_left
      end

      def get_y_labels
        max_value = @data.collect{|x| x[:data].max}.max
        min_value = @data.collect{|x| x[:data].min}.min
        range = max_value - min_value
        top_pad = range == 0 ? 10 : range / 20.0
        scale_range = (max_value + top_pad) - min_value

        scale_division = scale_divisions || (scale_range / 10.0)

        if scale_integers
          scale_division = scale_division < 1 ? 1 : scale_division.round
        end

        rv = []
        min_value.step( max_value, scale_division ) {|v| rv << v}
        return rv
      end

      def right_align
        1
      end

      def top_align
        1
      end
      alias :top_font :top_align

      def draw_data
        fieldheight = field_height
        fieldwidth = field_width
        line = @data.length
        
        for data in @data.reverse
          lpath = "M0 #@graph_height L"
          field_count = 0
          data[:data].each { |field|
            x = fieldwidth * field_count
            y = @graph_height - field * fieldheight
            lpath << "#{x} #{y} "
            field_count += 1
          }

          if area_fill
            field_count = 0
            @graph.add_element( "path", {
              "d" => "#{lpath} V#@graph_height Z",
              "class" => "fill#{line}"
            })
          end

          @graph.add_element( "path", {
            "d" => "M0 #@graph_height #{lpath}",
            "class" => "line#{line}"
          })

          if show_data_points || show_data_values
            field_count = 0
            data[:data].each { |field|
              if show_data_points
                @graph.add_element( "circle", {
                  "cx" => fieldwidth * field_count,
                  "cy" => @graph_height - field * fieldheight,
                  "r" => "2.5",
                  "class" => "dataPoint#{line}"
                })
              end
              if show_data_values
                @graph.add_element( "text", {
                  "x" => fieldwidth * field_count,
                  "y" => @graph_height - field * fieldheight - 6,
                  "class" => "dataPointLabel"
                }).text = field
              end
              field_count += 1
            }
          end
          line -= 1
        end
      end


      def get_css
        return <<EOL
/* default line styles */
.line1{
	fill: none;
	stroke: #ff0000;
	stroke-width: 1px;	
}
.line2{
	fill: none;
	stroke: #0000ff;
	stroke-width: 1px;	
}
.line3{
	fill: none;
	stroke: #00ff00;
	stroke-width: 1px;	
}
.line4{
	fill: none;
	stroke: #ffcc00;
	stroke-width: 1px;	
}
.line5{
	fill: none;
	stroke: #00ccff;
	stroke-width: 1px;	
}
.line6{
	fill: none;
	stroke: #ff00ff;
	stroke-width: 1px;	
}
.line7{
	fill: none;
	stroke: #00ffff;
	stroke-width: 1px;	
}
.line8{
	fill: none;
	stroke: #ffff00;
	stroke-width: 1px;	
}
.line9{
	fill: none;
	stroke: #ccc6666;
	stroke-width: 1px;	
}
.line10{
	fill: none;
	stroke: #663399;
	stroke-width: 1px;	
}
.line11{
	fill: none;
	stroke: #339900;
	stroke-width: 1px;	
}
.line12{
	fill: none;
	stroke: #9966FF;
	stroke-width: 1px;	
}
/* default fill styles */
.fill1{
	fill: #cc0000;
	fill-opacity: 0.2;
	stroke: none;
}
.fill2{
	fill: #0000cc;
	fill-opacity: 0.2;
	stroke: none;
}
.fill3{
	fill: #00cc00;
	fill-opacity: 0.2;
	stroke: none;
}
.fill4{
	fill: #ffcc00;
	fill-opacity: 0.2;
	stroke: none;
}
.fill5{
	fill: #00ccff;
	fill-opacity: 0.2;
	stroke: none;
}
.fill6{
	fill: #ff00ff;
	fill-opacity: 0.2;
	stroke: none;
}
.fill7{
	fill: #00ffff;
	fill-opacity: 0.2;
	stroke: none;
}
.fill8{
	fill: #ffff00;
	fill-opacity: 0.2;
	stroke: none;
}
.fill9{
	fill: #cc6666;
	fill-opacity: 0.2;
	stroke: none;
}
.fill10{
	fill: #663399;
	fill-opacity: 0.2;
	stroke: none;
}
.fill11{
	fill: #339900;
	fill-opacity: 0.2;
	stroke: none;
}
.fill12{
	fill: #9966FF;
	fill-opacity: 0.2;
	stroke: none;
}
/* default line styles */
.key1,.dataPoint1{
	fill: #ff0000;
	stroke: none;
	stroke-width: 1px;	
}
.key2,.dataPoint2{
	fill: #0000ff;
	stroke: none;
	stroke-width: 1px;	
}
.key3,.dataPoint3{
	fill: #00ff00;
	stroke: none;
	stroke-width: 1px;	
}
.key4,.dataPoint4{
	fill: #ffcc00;
	stroke: none;
	stroke-width: 1px;	
}
.key5,.dataPoint5{
	fill: #00ccff;
	stroke: none;
	stroke-width: 1px;	
}
.key6,.dataPoint6{
	fill: #ff00ff;
	stroke: none;
	stroke-width: 1px;	
}
.key7,.dataPoint7{
	fill: #00ffff;
	stroke: none;
	stroke-width: 1px;	
}
.key8,.dataPoint8{
	fill: #ffff00;
	stroke: none;
	stroke-width: 1px;	
}
.key9,.dataPoint9{
	fill: #cc6666;
	stroke: none;
	stroke-width: 1px;	
}
.key10,.dataPoint10{
	fill: #663399;
	stroke: none;
	stroke-width: 1px;	
}
.key11,.dataPoint11{
	fill: #339900;
	stroke: none;
	stroke-width: 1px;	
}
.key12,.dataPoint12{
	fill: #9966FF;
	stroke: none;
	stroke-width: 1px;	
}
EOL
      end
    end
  end
end
