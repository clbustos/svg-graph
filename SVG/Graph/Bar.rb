require 'rexml/document'
require 'SVG/Graph/Graph'

=begin

SVG::Graph::Bar - Create presentation quality SVG bar graphs easily

=SYNOPSIS

  require 'SVG/Graph/Bar'

  fields = %w(Jan Feb Mar);
  data_sales_02 = %w(12 45 21)

  graph = SVG::Graph::Bar.new({
    :height => 500,
    :width => 300,
    :fields => fields
  })
  
  graph.add_data({
    :data => data_sales_02,
    :title => 'Sales 2002'
  })
  
  print "Content-type: image/svg+xml\r\n\r\n"
  print graph.burn

=DESCRIPTION

This object aims to allow you to easily create high quality
SVG bar graphs. You can either use the default style sheet
or supply your own. Either way there are many options which can
be configured to give you control over how the graph is
generated - with or without a key, data elements at each point,
title, subtitle etc.

Copyright 2004 Sean E. Russell

=NOTES

The default stylesheet handles upto 12 data sets, if you
use more you must create your own stylesheet and add the
additional settings for the extra data sets. You will know
if you go over 12 data sets as they will have no style and
be in black.

=EXAMPLES

* http://germane-software.com/repositories/public/SVG/test.rb

=ACKNOWLEDGEMENTS

Leo Lapworth for creating the SVG::TT::Graph package which this Ruby
port is based on.

Stephen Morgan for creating the TT template and SVG.

=AUTHOR

Sean E. Russell <serATgermaneHYPHENsoftwareDOTcom>

=SEE ALSO

* SVG::Graph::Graph
* SVG::Graph::BarHorizontal

=end
module SVG
  module Graph
    class Bar < SVG::Graph::Graph
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


      # This method generates the SVG document, and is used by Graph::burn
      def get_svg
        rv = ""
        gen_svg.write( rv, 0, true )
        return rv
      end

      def gen_svg
        d = Document.new
        d << XMLDecl.new
        d << DocType.new( %q{svg PUBLIC "-//W3C//DTD SVG 1.0//EN" "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd"} )
        if style_sheet && style_sheet != ''
          d << ProcessingInstruction.new( "xml-stylesheet",
            %Q{href="#{style_sheet}" type="text/css"} )
        end
        root = d.add_element( "svg", {
          "width" => width,
          "height" => height,
          "viewBox" => "0 0 #{width} #{height}",
          "xmlns" => "http://www.w3.org/2000/svg",
          "xmlns:xlink" => "http://www.w3.org/1999/xlink"
        })
        root << Comment.new( " "+"\\"*66 )
        root << Comment.new( " Created with SVG::Graph " )
        root << Comment.new( " Sean Russell " )
        root << Comment.new( " Based on SVG::TT::Graph for Perl by"+
        " Leo Lapworth & Stephan Morgan " )
        root << Comment.new( " "+"/"*66 )

        if not(style_sheet && style_sheet != '')
          root << Comment.new(" include default stylesheet if none specified ")
          defs = root.add_element( "defs" )
          style = defs.add_element( "style", {"type"=>"text/css"} )
          style << CData.new( CSS )
        end

        root << Comment.new( "SVG Background" )
        root.add_element( "rect", {
          "width" => width,
          "height" => height,
          "x" => "0",
          "y" => "0",
          "class" => "svgBackground"
        })

        # Calculate graph area and boundries
        x = 0
        y = 0
        char_width = 9
        half_char_height = 2.5

        min_value = 9e20
        max_value = 0
        max_key_size = 0
        max_x_label_size = @config[:fields].max{ |a,b| 
          a.length <=> b.length
        }.length

        for data in @data
          dataset = data[:data]
          title = data[:title]

          dm = dataset.min
          min_value = dm < min_value ? dm : min_value
          dm = dataset.max
          max_value = dm > max_value ? dm : max_value
          max_key_size = title.length if title.length > max_key_size
        end

        h = height
        w = width
        h -= 20 if show_x_labels
        max_x_label_length = 0
        if rotate_x_labels
          max_x_label_length = max_x_label_size * char_width
          h -= max_x_label_length
        end

        stagger = 0
        if stagger_x_labels
          stagger = 17
          h -= stagger
        end

        h = h - 25 - stagger if show_x_title

        if show_y_labels
          h -= 10
          y += 10
        end

        if show_graph_title
          h -= 25
          y += 25
        end

        if show_graph_subtitle
          h -= 10
          y += 10
        end

        key_box_size = 12
        key_padding = 5

        if key && key_position == :right
          w = w - (max_key_size * (char_width - 1)) - (key_box_size * 3 )
        elsif key && key_position == :bottom
          if data.size > 4
            h -= (data.size + 1) * (key_box_size + key_padding)
          else
            h -= 4 * (key_box_size + key_padding)
          end
        end

        minvalue = min_value
        minvalue = min_scale_value if min_scale_value

        base_line = h + y

        temp = max_value - minvalue
        top_pad = temp == 0 ? 10 : temp / 20.0

        scale_range = (max_value + top_pad) - minvalue

        scale_division = scale_divisions || (scale_range / 10.0)

        if scale_integers
          scale_division = scale_division < 1 ? 1 : scale_division.round
        end

        dx = @config[:fields].size
        data_widths_x = w / dx
        dw = data_widths_x

        half_label_width = @config[:fields][0].length/2 * char_width

        space_b4_y_axis = 0
        if half_label_width > (dw / 2)
          space_b4_y_axis = half_label_width - (dw / 2)
          if key && key_position == :right
            w = w - space_b4_y_axis
          else
            w = w - (space_b4_y_axis * 2)
          end
          x = x + space_b4_y_axis
        end

        max_value_length = max_value.to_s.length

        max_value_length_px = max_value_length * char_width

        if show_y_labels && space_b4_y_axis < max_value_length_px
          if max_value_length < 2
            w = w - (max_value_length * (char_width * 2)) - char_width
            x = x + (max_value_length * (char_width * 2)) + char_width 
          else
            w = w - max_value_length_px + char_width
            x = x + max_value_length_px + char_width
          end
        end

        if show_y_title && space_b4_y_axis < max_value_length_px
          w = w - 25
          x = x + 25
        end

        # Background
        root.add_element( "rect", {
          "x" => x,
          "y" => y,
          "width" => w,
          "height" => h,
          "class" => "graphBackground"
        })

        # Axis
        root.add_element( "path", {
          "d" => "M #{x} #{y} v#{h}",
          "class" => "axis",
          "id" => "xAxis"
        })
        root.add_element( "path", {
          "d" => "M #{x} #{base_line} h#{w}",
          "class" => "axis",
          "id" => "yAxis"
        })

        dx = @config[:fields].size

        data_widths_x = w / dx

        dw = (data_widths_x*100).truncate / 100.0

        i = dw
        count = 0

        if bar_gap
          bargap = 10
          bargap = dw / 2 if dw < bargap
        else
          bargap = 0
        end

        stagger_count = 0
        if show_x_labels
          for field in @config[:fields]
            text = root.add_element( "text" )
            text.attributes["class"] = "xAxisLabels"
            text.text = field

            tx = x + (dw / 2) - (bargap / 2)
            ty = base_line + 15
            tt = x + ( dw / 2 ) - ( bargap / 2 ) - half_char_height

            if count == 0
              i -= dw
            else
              tx += i
              tt += i
              if stagger_count == 2
                stagger_count = 0
              else
                ty += stagger
                root.add_element( "path", {
                  "d" => "M#{tx} #{base_line}, v#{stagger}",
                  "class" => "staggerGuideLine"
                })
              end
            end

            text.attributes["x"] = tx
            text.attributes["y"] = ty
            if rotate_x_labels
              text.attributes["transform"] = "rotate( 90 #{tt} #{ty} )"
              text.attributes["style"] = "text-anchor: start"
            end
            
            i += dw
            count += 1
            stagger_count += 1
          end
        end

        dy = scale_range / scale_division
        y_marker_height = h.to_f / dy
        dy = y_marker_height.to_i
        count = 0
        y_value = min_scale_value
        if show_y_labels
          while (dy * count) < h
            root.add_element( "text", {
              "x" => x - 5,
              "y" => base_line - (dy * count),
              "class" => "yAxisLabels"
            }).text = y_value
            if count != 0
              root.add_element( "path", {
                "d" => "M#{x} #{base_line - (dy * count)} h#{w}",
                "class" => "guideLines"
              })
            end
            y_value = y_value + scale_division
            count += 1
          end
        end

        if show_x_title 
          y_xtitle = show_x_labels ? 35 : 15
          root.add_element( "text", {
            "x" => (w / 2) + x,
            "y" => h + y + y_xtitle + stagger + max_x_label_length,
            "class" => "xAxisTitle"
          }).text = x_title
        end	

        if show_y_title 
          text = root.add_element( "text", { "class" => "yAxisTitle" } )
          text.text = y_title
          if y_title_text_direction == :tb
            text.attributes["x"] = 12
            text.attributes["y"] = (h / 2) + y
            text.attributes["style"] = "writing-mode: tb;"
          else
            text.attributes["transform"]="translate(15, #{(h/2)+y}) rotate(270)"
          end
        end

        bar_width = dw - bargap
        divider = dy / scale_division

        xcount = 0

        subbar_width = bar_width
        subbar_width /= @data.length if stack == :side
        @config[:fields].each_index { |i|
          dcount = 1
          for dataset in @data
            # X1
            p1 = (dw * xcount) + x
            # Y1
            p2 = base_line
            # to Y2
            p3 = base_line - (dataset[:data][i] * divider)
            # to X2
            p4 = subbar_width
            case stack
            when :side
              p1 += (dcount-1) * subbar_width
            when :top
            else
            end
            root.add_element( "path", {
              "class" => "fill#{dcount}",
              "d" => "M#{p1} #{p2} V#{p3} h#{p4} V#{p2} Z"
            })
            if show_data_values
              root.add_element( "text", {
                "x" => p1 + ((dw-bargap)/2)-(stack==:side ? subbar_width/2 : 0),
                "y" => p3 - 6,
                "class" => "dataPointLabel"
              } ).text = dataset[:data][i].to_s
            end
            dcount += 1
          end
          xcount += 1
        }

        key_count = 1
        key_padding = 5
        if key && key_position == :right
          for dataset in @data
            yval = y + (key_box_size * key_count) + (key_count * key_padding)
            root.add_element( "rect", {
              "x" => x + w + 20,
              "y" => yval,
              "width" => key_box_size,
              "height" => key_box_size,
              "class" => "key#{key_count}"
            })
            root.add_element( "text", {
              "x" => x + w + 20 + key_box_size + key_padding,
              "y" => yval + key_box_size,
              "class" => "keyText"
            }).text = dataset[:title]
            key_count += 1
          end
        elsif key && key_position == :bottom
          y_key = base_line
          y_key += 25 if show_x_title
          if rotate_x_labels && show_x_labels
            y_key = y_key + max_x_label_length
          elsif show_x_labels && stagger < 1
            y_key = y_key + 20
          end

          y_key_start = y_key
          x_key = x
          for dataset in @data
            if key_count == 4 || key_count == 7 || key_count == 10
              x_key += 200
              y_key -= (key_box_size * 4) - 2
            end
            wh = key_box_size
            bs = y_key + (key_box_size * key_count) + 
            (key_count * key_padding) + stagger
            cl = "key#{key_count}"
            root.add_element( "rect", {
              "x" => x_key,
              "y" => bs,
              "width" => wh,
              "height" => wh,
              "class" => cl
            })
            root.add_element( "text", {
              "x" => x_key + key_box_size + key_padding,
              "y" => bs + key_box_size,
              "width" => wh,
              "height" => wh,
              "class" => cl
            }).text = dataset[:title]
            key_count += 1
          end
        end

        if show_graph_title
          root.add_element( "text", {
            "x" => width / 2,
            "y" => "15",
            "class" => "mainTitle"
          }).text = graph_title
        end

        if show_graph_subtitle
          y_subtitle = show_graph_title ? 30 : 15
          root.add_element("text", {
            "x" => width / 2,
            "y" => y_subtitle,
            "class" => "subTitle"
          }).text = graph_subtitle
        end

        return d
      end

      ##########################################################################
      # The following is a list of the methods which are available
      # to change the config of the graph object after it has been
      # created.
      #   
      #   value = graph.method
      #   graph.method = value
      ##########################################################################


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
      #   (Bool) Show the value of each element of data on the graph
      # [bar_gap]
      #   Whether to have a gap between the bars or not, default
      #   is true, set to false if you don't want gaps.
      # [min_scale_value]
      #   The point at which the Y axis starts, defaults to '0',
      #   if set to nil it will default to the minimum data value.
      # [show_x_labels]
      #   Whether to show labels on the X axis or not, defaults
      #   to true, set to false if you want to turn them off.
      # [stagger_x_labels]
      #   This puts the labels at alternative levels so if they
      #   are long field names they will not overlap so easily.
      #   Default it false, to turn on set to true.
      # [rotate_x_labels]
      #   This turns the X axis labels by 90 degrees.
      #   Default it false, to turn on set to true.
      # [show_y_labels]
      #   Whether to show labels on the Y axis or not, defaults
      #   to true, set to false if you want to turn them off.
      # [scale_integers]
      #   Ensures only whole numbers are used as the scale divisions.
      #   Default it false, to turn on set to true. This has no effect if 
      #   scale divisions are less than 1.
      # [scale_divisions]
      #   This defines the gap between markers on the Y axis,
      #   default is a 10th of the max_value, e.g. you will have
      #   10 markers on the Y axis. NOTE: do not set this too
      #   low - you are limited to 999 markers, after that the
      #   graph won't generate.
      # [show_x_title]
      #   Whether to show the title under the X axis labels,
      #   default is false, set to true to show.
      # [x_title]
      #   What the title under X axis should be, e.g. 'Months'.
      # [show_y_title]
      #   Whether to show the title under the Y axis labels,
      #   default is false, set to true to show.
      # [y_title_text_direction]
      #   Aligns writing mode for Y axis label. 
      #   Defaults to :bt (Bottom to Top).
      #   Change to :tb (Top to Bottom) to reverse.
      # [y_title]
      #   What the title under Y axis should be, e.g. 'Sales in thousands'.
      # [show_graph_title]
      #   Whether to show a title on the graph, defaults
      #   to false, set to true to show.
      # [graph_title]
      #   What the title on the graph should be.
      # [show_graph_subtitle]
      #   Whether to show a subtitle on the graph, defaults
      #   to false, set to true to show.
      # [graph_subtitle]
      #   What the subtitle on the graph should be.
      # [key]
      #   Whether to show a key, defaults to false, set to
      #   true if you want to show it.
      # [key_position]
      #   Where the key should be positioned, defaults to
      #   :right, set to :bottom if you want to move it.
      # [stack]
      #   How to stack data sets.  :overlap overlaps bars with
      #   transparent colors, :top stacks bars on top of one another,
      #   :side stacks the bars side-by-side. Defaults to :overlap.
      attr_accessor :height, :width, :style_sheet, :show_data_values, :bar_gap, :min_scale_value, :show_x_labels, :stagger_x_labels, :rotate_x_labels, :show_y_labels, :scale_integers, :scale_divisions, :show_x_title, :x_title, :show_y_title, :y_title_text_direction, :y_title, :show_graph_title, :graph_title, :show_graph_subtitle, :graph_subtitle, :key, :key_position, :stack


      def init
        raise "fields was not supplied or is empty" unless @config[:fields] &&
        @config[:fields].kind_of?(Array) &&
        @config[:fields].length > 0
      end


      def set_defaults 
        for k,v in {
          :width				        => 500,
          :height			          => 300,
          :show_data_values     => true,

          :min_scale_value      => 0,
          :bar_gap			        => true,

          :show_x_labels        => true,
          :stagger_x_labels     => false,
          :rotate_x_labels      => false,

          :show_y_labels        => true,
          :scale_integers       => false,

          :show_x_title         => false,
          :x_title              => 'X Field names',

          :show_y_title         => false,
          :y_title_text_direction => :bt,
          :y_title              => 'Y Scale',

          :show_graph_title		  => false,
          :graph_title			    => 'Graph Title',
          :show_graph_subtitle	=> false,
          :graph_subtitle		    => 'Graph Sub Title',
          :key					        => false, 
          :key_position			    => :right, # bottom or right

          :stack                => :overlap,
          }
          m = k.to_s + "="
          self.send( m, v ) if methods.include? m
        end
      end

      CSS =<<EOL
/* Copy from here for external style sheet */
.svgBackground{
	fill:#ffffff;
}
.graphBackground{
	fill:#f0f0f0;
}

/* graphs titles */
.mainTitle{
	text-anchor: middle;
	fill: #000000;
	font-size: 14px;
	font-family: "Arial", sans-serif;
	font-weight: normal;
}
.subTitle{
	text-anchor: middle;
	fill: #999999;
	font-size: 12px;
	font-family: "Arial", sans-serif;
	font-weight: normal;
}

.axis{
	stroke: #000000;
	stroke-width: 1px;
}

.guideLines{
	stroke: #666666;
	stroke-width: 1px;
	stroke-dasharray: 5 5;
}

.xAxisLabels{
	text-anchor: middle;
	fill: #000000;
	font-size: 12px;
	font-family: "Arial", sans-serif;
	font-weight: normal;
}

.yAxisLabels{
	text-anchor: end;
	fill: #000000;
	font-size: 12px;
	font-family: "Arial", sans-serif;
	font-weight: normal;
}

.xAxisTitle{
	text-anchor: middle;
	fill: #ff0000;
	font-size: 14px;
	font-family: "Arial", sans-serif;
	font-weight: normal;
}

.yAxisTitle{
	fill: #ff0000;
	text-anchor: middle;
	font-size: 14px;
	font-family: "Arial", sans-serif;
	font-weight: normal;
}

.dataPointLabel{
	fill: #000000;
	text-anchor:middle;
	font-size: 10px;
	font-family: "Arial", sans-serif;
	font-weight: normal;
}

.staggerGuideLine{
	fill: none;
	stroke: #000000;
	stroke-width: 0.5px;	
}
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
.keyText{
	fill: #000000;
	text-anchor:start;
	font-size: 10px;
	font-family: "Arial", sans-serif;
	font-weight: normal;
}
/* End copy for external style sheet */
EOL
    end
  end
end
