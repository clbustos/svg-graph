require 'rexml/document'
require 'SVG/Graph/Graph'
require 'SVG/Graph/BarBase'

module SVG
  module Graph
    # = SVG::Graph::Bar 
    #
    # == @ANT_VERSION@
    #
    # === Create presentation quality SVG bar graphs easily
    #
    # == Synopsis
    #
    #   require 'SVG/Graph/Bar'
    #
    #   fields = %w(Jan Feb Mar);
    #   data_sales_02 = %w(12 45 21)
    #
    #   graph = SVG::Graph::Bar.new({
    #     :height => 500,
    #     :width => 300,
    #     :fields => fields
    #   })
    #
    #   graph.add_data({
    #     :data => data_sales_02,
    #     :title => 'Sales 2002'
    #   })
    #
    #   print "Content-type: image/svg+xml\r\n\r\n"
    #   print graph.burn
    #
    # == Description
    #
    # This object aims to allow you to easily create high quality
    # SVG bar graphs. You can either use the default style sheet
    # or supply your own. Either way there are many options which can
    # be configured to give you control over how the graph is
    # generated - with or without a key, data elements at each point,
    # title, subtitle etc.
    #
    # Copyright 2004 Sean E. Russell
    #
    # == Notes
    #
    # The default stylesheet handles upto 12 data sets, if you
    # use more you must create your own stylesheet and add the
    # additional settings for the extra data sets. You will know
    # if you go over 12 data sets as they will have no style and
    # be in black.
    #
    # == Examples
    #
    # * http://germane-software.com/repositories/public/SVG/test.rb
    #
    # == Acknowledgements
    #
    # Leo Lapworth for creating the SVG::TT::Graph package which this Ruby
    # port is based on.
    #
    # Stephen Morgan for creating the TT template and SVG.
    #
    # == Author
    #
    # Sean E. Russell <serATgermaneHYPHENsoftwareDOTcom>
    #
    # == See also
    #
    # * SVG::Graph::Graph
    # * SVG::Graph::BarHorizontal
    # * SVG::Graph::BarLine
    # * SVG::Graph::Line
    # * SVG::Graph::Pie
    # * SVG::Graph::TimeSeries
    class Bar < BarBase
      include REXML
      # The constructor takes a hash reference, fields (the names for each
      # field on the X axis) MUST be set, all other values are defaulted to 
      # those shown above - with the exception of style_sheet which defaults
      # to using the internal style sheet.
      #
      #    require 'SVG/Graph/Bar'
      #    
      #    # Field names along the X axis
      #    fields = %w(Jan Feb Mar)
      #    
      #    graph = SVG::Graph::Bar.new({
      #       # Required
      #       :fields => fields,
      #       
      #       # Optional - defaults shown
      #       :height            => 500,
      #       :width             => 300,
      #       :show_data_values  => true,
      #       
      #       :min_scale_value   => 0,
      #       :stagger_x_labels  => false,
      #       :rotate_x_labels   => false,
      #       :bar_gap           => true,
      #       
      #       :show_x_labels     => true,
      #       :show_y_labels     => true,
      #       :scale_integers    => false,
      #       :scale_divisions   => 0,
      #       
      #       :show_x_title      => false,
      #       :x_title           => 'X Field names',
      #       
      #       :show_y_title      => false,
      #       :y_title_text_direction => :bt,
      #       :y_title           => 'Y Scale',
      #       
      #       :show_graph_title  => false,
      #       :graph_title       => 'Graph Title',
      #       :show_graph_subtitle   => false,
      #       :graph_subtitle        => 'Graph Sub Title',
      #       
      #       :key                   => false,
      #       :key_position          => :right,
      #       
      #       # Optional - defaults to using internal stylesheet
      #       :style_sheet       => '/includes/graph.css'
      #    })
      def initialize config
        super
      end

      def get_x_labels
        @config[:fields]
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

      def x_label_offset( width )
        width / 2.0
      end

      def top_align
        1
      end
      alias :top_font :top_align

      def draw_data
        fieldwidth = field_width
        fieldheight = field_height
        bargap = bar_gap ? (fieldwidth < 10 ? fieldwidth / 2 : 10) : 0

        subbar_width = fieldwidth - bargap
        subbar_width /= @data.length if stack == :side
        x_mod = (@graph_width-bargap)/2 - (stack==:side ? subbar_width/2 : 0)
        # Y1
        p2 = @graph_height
        # to X2
        field_count = 0
        @config[:fields].each_index { |i|
          dataset_count = 0
          for dataset in @data
            # X1
            p1 = (fieldwidth * field_count)
            # to Y2
            p3 = @graph_height - (dataset[:data][i] * fieldheight)
            p1 += subbar_width * dataset_count if stack == :side
            @graph.add_element( "path", {
              "class" => "fill#{dataset_count+1}",
              "d" => "M#{p1} #{p2} V#{p3} h#{subbar_width} V#{p2} Z"
            })
            if show_data_values
              @graph.add_element( "text", {
                "x" => p1 + subbar_width/2,
                "y" => p3 - 6,
                "class" => "dataPointLabel"
              } ).text = dataset[:data][i].to_s
            end
            dataset_count += 1
          end
          field_count += 1
        }
      end
    end
  end
end
