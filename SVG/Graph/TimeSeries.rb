require 'SVG/Graph/Plot'
require 'parsedate'

module SVG
  module Graph
    # = SVG::Graph::TimeSeries 
    #
    # == @ANT_VERSION@
    #
    # === For creating SVG plots of scalar temporal data
    # 
    # = Synopsis
    # 
    #   require 'SVG/Graph/TimeSeriess'
    # 
    #   # Data sets are x,y pairs
    #   data1 = ["6/17/72", 11,    "1/11/72", 7,    "4/13/04 17:31", 11, 
    #           "9/11/01", 9,    "9/1/85", 2,    "9/1/88", 1,    "1/15/95", 13]
    #   data2 = ["8/1/73", 18,    "3/1/77", 15,    "10/1/98", 4, 
    #           "5/1/02", 14,    "3/1/95", 6,    "8/1/91", 12,    "12/1/87", 6, 
    #           "5/1/84", 17,    "10/1/80", 12]
    #
    #   graph = SVG::Graph::TimeSeries.new( {
    #     :width => 640,
    #     :height => 480,
    #     :graph_title => title,
    #     :show_graph_title => true,
    #     :no_css => true,
    #     :key => true,
    #     :scale_x_integers => true,
    #     :scale_y_integers => true,
    #     :min_x_value => 0,
    #     :min_y_value => 0,
    #     :show_data_labels => true,
    #     :show_x_guidelines => true,
    #     :show_x_title => true,
    #     :x_title => "Time",
    #     :show_y_title => true,
    #     :y_title => "Ice Cream Cones",
    #     :y_title_text_direction => :bt,
    #     :stagger_x_labels => true,
    #     :x_label_format => "%m/%d/%y",
    #   })
    #   
    #   graph.add_data({
    #   	:data => projection
    # 	  :title => 'Projected',
    #   })
    # 
    #   graph.add_data({
    #   	:data => actual,
    # 	  :title => 'Actual',
    #   })
    #   
    #   print graph.burn()
    # 
    # = Description
    # 
    # Produces a graph of temporal scalar data.
    # 
    # = Notes
    # 
    # The default stylesheet handles upto 10 data sets, if you
    # use more you must create your own stylesheet and add the
    # additional settings for the extra data sets. You will know
    # if you go over 10 data sets as they will have no style and
    # be in black.
    #
    # Unlike the other types of charts, data sets must contain x,y pairs:
    #
    #   [ "12:30", 2 ]          # A data set with 1 point: ("12:30",2)
    #   [ "01:00",2, "14:20",6] # A data set with 2 points: ("01:00",2) and 
    #                                                       ("14:20",6)  
    #
    # Note that multiple data sets within the same chart can differ in length, 
    # and that the data in the datasets needn't be in order; they will be ordered
    # by the plot along the X-axis.
    # 
    # The dates must be parseable by ParseDate, but otherwise can be
    # any order of magnitude (seconds within the hour, or years)
    # 
    # = See also
    # 
    # * SVG::Graph::Graph
    # * SVG::Graph::BarHorizontal
    # * SVG::Graph::Bar
    # * SVG::Graph::Line
    # * SVG::Graph::Pie
    # * SVG::Graph::Plot
    class TimeSeries < Plot
      # In addition to the defaults set by Graph and Plot, sets:
      # [x_label_format] '%Y-%m-%d %H:%M:%S'
      def set_defaults
        super
        init_with( 
          #:max_time_span     => '',
          #:timescale_divisions   => '',
          :x_label_format    => '%Y-%m-%d %H:%M:%S'
        )
      end

      # The format string use do format the X axis labels.
      # See Time::strformat
      attr_accessor :x_label_format

      def add_data data
        @data = [] unless @data
        if not(data[:data] and data[:data].kind_of? Array)
          raise "No data provided by #{conf.inspect}"
        end

        x = []
        y = []
        data[:data].each_index {|i|
          if i%2 == 0
            arr = ParseDate.parsedate( data[:data][i] )
            t = Time.local( *arr[0,6].compact )
            x << t.to_i
          else
            y << data[:data][i]
          end
        }
        sort_two( x, y )
        data[:data] = [x,y]
        @data << data
      end


      protected
      def format x, y
        Time.at( x ).to_s
      end

      def get_x_labels
        super.collect { |v| Time.at(v).strftime( x_label_format ) }
      end
    end
  end
end
