require 'rexml/document'
require 'SVG/Graph/BarBase'

module SVG
  module Graph
    # =SVG::Graph::BarHorizontal
    #
    # ==@ANT_VERSION@
    #
    #
    # ===Create presentation quality SVG horitonzal bar graphs easily
    # 
    # ==Synopsis
    # 
    #   require 'SVG/Graph/BarHorizontal'
    #   
    #   fields = %w(Jan Feb Mar)
    #   data_sales_02 = %w(12 45 21)
    #   
    #   graph = SVG::Graph::BarHorizontal.new({
    #     :height => 500,
    #     :width => 300,
    #     :fields => fields,
    #   })
    #   
    #   graph.add_data({
    #     :data => data_sales_02,
    #     :title => 'Sales 2002',
    #   })
    #   
    #   print "Content-type: image/svg+xml\r\n\r\n"
    #   print graph.burn
    # 
    # ==Description
    # 
    # This object aims to allow you to easily create high quality
    # SVG horitonzal bar graphs. You can either use the default style sheet
    # or supply your own. Either way there are many options which can
    # be configured to give you control over how the graph is
    # generated - with or without a key, data elements at each point,
    # title, subtitle etc.
    # 
    # Copyright 2004 Sean E. Russell
    # 
    # ==Examples
    # 
    # * http://germane-software.com/repositories/public/SVG/test.rb
    # 
    # ==See also
    # 
    # * SVG::Graph::Graph
    # * SVG::Graph::Bar
    #
    # =Options
    #
    # These options can be set in the config passed to the initializer,
    # or they can be set via "=" methods after object instantiation.
    #
    # [height] 
    #   Set the height of the graph box, this is the total height
    #   of the SVG box created - not the graph it self which auto
    #   scales to fix the space.
    # [width]
    #   Set the width of the graph box, this is the total width
    #   of the SVG box created - not the graph it self which auto
    #   scales to fix the space.
    # [style_sheet]
    #   Set the path to an external stylesheet, set to '' if
    #   you want to revert back to using the defaut internal version.
    #   
    #   To create an external stylesheet create a graph using the
    #   default internal version and copy the stylesheet section to
    #   an external file and edit from there.
    # [show_data_values]
    #   Show the value of each element of data on the graph
    # [bar_gap]
    #   Whether to have a gap between the bars or not, default
    #   is true, set to false if you don't want gaps.
    # [min_scale_value]
    #   The point at which the Y axis starts, defaults to false
    #   if set to nil it will default to the minimum data value.
    # [show_x_labels]
    #   Whether to show labels on the X axis or not, defaults
    #   to 1, set to false if you want to turn them off.
    # [stagger_x_labels]
    #   This puts the labels at alternative levels so if they
    #   are long field names they will not overlap so easily.
    #   Default it false to turn on set to true.
    # [show_y_labels]
    #   Whether to show labels on the Y axis or not, defaults
    #   to 1, set to false if you want to turn them off.
    # [scale_integers]
    #   Ensures only whole numbers are used as the scale divisions.
    #   Default it false to turn on set to true. This has no effect if 
    #   scale divisions are less than 1.
    # [scale_divisions]
    #   This defines the gap between markers on the X axis,
    #   default is a 10th of the max_value, e.g. you will have
    #   10 markers on the X axis. NOTE: do not set this too
    #   low - you are limited to 999 markers, after that the
    #   graph won't generate.
    # [show_x_title]
    #   Whether to show the title under the X axis labels,
    #   default is false set to true to show.
    # [x_title]
    #   What the title under X axis should be, e.g. 'Months'.
    # [show_y_title]
    #   Whether to show the title under the Y axis labels,
    #   default is false set to true to show.
    # [y_title_text_direction]
    #   Aligns writing mode for Y axis label. Defaults to :bt 
    #   (Bottom to Top). Change to :tb (Top to Bottom) to reverse.
    # [y_title]
    #   What the title under Y axis should be, e.g. 'Sales in thousands'.
    # [show_graph_title]
    #   Whether to show a title on the graph,
    #   default is false set to true to show.
    # [graph_title]
    #   What the title on the graph should be.
    # [show_graph_subtitle]
    #   Whether to show a subtitle on the graph,
    #   default is false, set to true to show.
    # [graph_subtitle]
    #   What the subtitle on the graph should be.
    # [key]
    #   Whether to show a key, defaults to false, set to
    #   true if you want to show it.
    # [key_position]
    #   Where the key should be positioned, defaults to
    #   :right, set to :bottom if you want to move it.
    # [stack]
    #   How to position bars from multiple data sets. Can be one of
    #   :overlap, :side, or :top
    class BarHorizontal < BarBase

      def set_defaults
        super
        init_with( {
          :rotate_y_labels    => true,
          :show_x_guidelines  => true,
          :show_y_guidelines  => false
        })
      end
  
      def get_x_labels
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

      def get_y_labels
        @config[:fields]
      end

      def y_label_offset( height )
        height / -2.0
      end

      def right_align
        1
      end
      alias :right_font :right_align

      def draw_data
        fieldheight = field_height
        fieldwidth = field_width
        bargap = bar_gap ? (fieldheight < 10 ? fieldheight / 2 : 10) : 0

        subbar_height = fieldheight - bargap
        subbar_height /= @data.length if stack == :side
        
        field_count = 1
        y_mod = (subbar_height / 2) + (font_size / 2)
        @config[:fields].each_index { |i|
          dataset_count = 0
          for dataset in @data
            y = @graph_height - (fieldheight * field_count)
            y += (subbar_height * dataset_count) if stack == :side
            x = dataset[:data][i] * fieldwidth

            @graph.add_element( "path", {
              "d" => "M0 #{y} H#{x} v#{subbar_height} H0 Z",
              "class" => "fill#{dataset_count+1}"
            })
            if show_data_values
              @graph.add_element( "text", {
                "x" => x + 5,
                "y" => y + y_mod,
                "class" => "dataPointLabel",
                "style" => "text-anchor: start;"
              }).text = dataset[:data][i]
            end
            dataset_count += 1
          end
          field_count += 1
        }
      end
    end
  end
end
