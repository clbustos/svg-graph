require 'SVG/Graph/Graph'

module SVG
  module Graph
    # A graph of a scalar plot of data.
    # 
    # Data are [ x1, y1, x2, y2, ... ]
    class Plot < Graph

      def set_defaults
        init_with( 
          :show_data_points  => true,
          :area_fill         => false,
          :stacked           => 0
        )
        self.top_align = self.right_align = self.top_font = self.right_font = 1
      end

      def keys
        @data.collect{ |x| x[:title] }
      end

      attr_accessor :scale_x_divisions, :scale_y_divisions, 
        :scale_x_integers, :scale_y_integers, :area_fill, :show_data_points,
        :min_x_value, :min_y_value


      def calculate_left_margin
        super
        label_left = get_x_labels[0].to_s.length / 2 * font_size * 0.6
        @border_left = label_left if label_left > @border_left
      end

      def calculate_right_margin
        super
        label_right = get_x_labels[-1].to_s.length / 2 * font_size * 0.6
        @border_right = label_right if label_right > @border_right
      end


      def x_range
        max_value = @data.collect{|x| 
          max = 0
          x[:data].each_index {|idx| 
            max = (max > x[:data][idx] ? max : x[:data][idx]) if idx % 2 == 0
          }
          max
        }.max
        min_value = @data.collect{|x| 
          min = 9e10
          x[:data].each_index {|idx| 
            min = (min < x[:data][idx] ? min : x[:data][idx]) if idx % 2 == 0
          }
          min
        }.min
        min_value = min_value<min_x_value ? min_value : min_x_value if min_x_value
        [min_value, max_value]
      end

      def get_x_labels
        min_value, max_value = x_range

        range = max_value - min_value
        right_pad = range == 0 ? 10 : range / 20.0
        scale_range = (max_value + right_pad) - min_value

        scale_division = scale_x_divisions || (scale_range / 10.0)

        if scale_x_integers
          scale_division = scale_division < 1 ? 1 : scale_division.round
        end

        rv = []
        max_value = max_value%scale_division == 0 ? 
          max_value : max_value + scale_division
        min_value.step( max_value, scale_division ) {|v| rv << v}
        return rv
      end


      def y_range
        max_value = @data.collect{|x| 
          max = 0
          x[:data].each_index {|idx| 
            max = (max > x[:data][idx] ? max : x[:data][idx]) if idx % 2 == 1
          }
          max
        }.max
        min_value = @data.collect{|x| 
          min = 9e10
          x[:data].each_index {|idx| 
            min = (min < x[:data][idx] ? min : x[:data][idx]) if idx % 2 == 1
          }
          min
        }.min
        min_value = min_value<min_y_value ? min_value : min_y_value if min_y_value
        return [min_value, max_value]
      end

      def get_y_labels
        min_value, max_value = y_range

        range = max_value - min_value
        top_pad = range == 0 ? 10 : range / 20.0
        scale_range = (max_value + top_pad) - min_value

        scale_division = scale_y_divisions || (scale_range / 10.0)

        if scale_y_integers
          scale_division = scale_division < 1 ? 1 : scale_division.round
        end

        rv = []
        max_value = max_value%scale_division == 0 ? 
          max_value : max_value + scale_division
        min_value.step( max_value, scale_division ) {|v| rv << v}
        return rv
      end

      def draw_data
        line = 1
        
        xlabels = get_x_labels
        x_min, x_max = xlabels[0], xlabels[-1]
        ylabels = get_y_labels
        y_min, y_max = ylabels[0], ylabels[-1]
        x_step = (@graph_width.to_f - font_size*2) / (x_max-x_min)
        y_step = (@graph_height.to_f -  font_size*2) / (y_max-y_min)

        for data in @data
          x_points = []
          y_points = []
          data[:data].each_index {|i|
            (i%2 == 0 ? x_points : y_points) << data[:data][i]
          }
          sort_two( x_points, y_points )

          lpath = "L"
          x_start = 0
          y_start = 0
          x_points.each_index { |idx|
            x = (x_points[idx] -  x_min) * x_step
            y = @graph_height - (y_points[idx] -  y_min) * y_step
            x_start, y_start = x,y if idx == 0
            lpath << "#{x} #{y} "
          }

          if area_fill
            @graph.add_element( "path", {
              "d" => "M0 #@graph_height #{lpath} V#@graph_height Z",
              "class" => "fill#{line}"
            })
          end

          @graph.add_element( "path", {
            "d" => "M#{x_start} #{y_start} #{lpath}",
            "class" => "line#{line}"
          })

          if show_data_points || show_data_values
            x_points.each_index { |idx|
              x = (x_points[idx] -  x_min) * x_step
              y = @graph_height - (y_points[idx] -  y_min) * y_step
              if show_data_points
                @graph.add_element( "circle", {
                  "cx" => x,
                  "cy" => y,
                  "r" => "2.5",
                  "class" => "dataPoint#{line}"
                })
              end
              make_datapoint_text( x, y-6, y_points[idx] )
            }
          end
          line += 1
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

      def sort_two( a, b, lo=0, hi=a.length-1 )
        if lo < hi
          p = partition(a,b,lo,hi)
          sort_two(a,b, lo, p-1)
          sort_two(a,b, p+1, hi)
        end
        [a,b]
      end
      def partition( a, b, lo, hi )
        p = a[lo]
        l = lo
        z = lo+1
        while z <= hi
          if a[z] < p
            l += 1
            a[z],a[l],b[z],b[l] = a[l],a[z],b[l],b[z]
          end
          z += 1
        end
        a[lo],a[l],b[lo],b[l] = a[l],a[lo],b[l],b[lo]
        l
      end
    end
  end
end
