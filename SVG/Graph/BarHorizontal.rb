require 'rexml/document'
require 'SVG/Graph/Bar'

=begin

SVG::Graph::BarHorizontal - Create presentation quality SVG horitonzal bar 
graphs easily

=SYNOPSIS

  require 'SVG/Graph/BarHorizontal'

  fields = %w(Jan Feb Mar)
  data_sales_02 = %w(12 45 21)
  
  graph = SVG::Graph::BarHorizontal.new({
  	:height => 500,
    :width => 300,
    :fields => fields,
  })
  
  graph.add_data({
  	:data => data_sales_02,
    :title => 'Sales 2002',
  })
  
  print "Content-type: image/svg+xml\r\n\r\n"
  print graph.burn

=DESCRIPTION

This object aims to allow you to easily create high quality
SVG horitonzal bar graphs. You can either use the default style sheet
or supply your own. Either way there are many options which can
be configured to give you control over how the graph is
generated - with or without a key, data elements at each point,
title, subtitle etc.

Copyright 2004 Sean E. Russell

=EXAMPLES

* http://germane-software.com/repositories/public/SVG/test.rb

=SEE ALSO

* SVG::Graph::Graph
* SVG::Graph::Bar
=end
module SVG
  module Graph
    class BarHorizontal < Bar
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

        min_value = 9e20
        max_value = 0
        max_key_size = 0

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

        if show_y_title
          w -= 20
          x += 20
        end
        if show_y_labels
          max_ylabel_length = @config[:fields].max {|a,b| a.length <=> b.length }.length
          space_b4_axis = char_width * max_ylabel_length

          w -= (space_b4_axis + char_width)
          x += space_b4_axis + char_width
        end

        if max_ylabel_length == 1
          w -= 5
          x += 5
        end

        if show_x_labels
          w -= 20
          if !(show_y_labels || show_y_title)
            w -= 10
            x += 10
          end
          if min_scale_value.to_s.length > 1
            padding_for_labels = char_width * min_scale_value.to_s.length
            w -= (padding_for_labels / 2)
            x += (padding_for_labels / 2)
          end
        end

        h -= 20 if show_x_labels

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
          w = w - (max_key_size * (char_width - 1)) - (key_box_size)
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

        scale_division = scale_divisions || scale_range / 10.0

        if scale_integers
          scale_division = scale_division < 1 ? 1 : scale_division.round
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

        dy = @config[:fields].size

        data_widths_y = h / dy

        dh = (data_widths_y*100).truncate / 100.0

        i = dh
        count = 0

        if show_y_labels
          for field in @config[:fields]
            text = root.add_element( "text" )
            text.attributes["class"] = "yAxisLabels"
            text.attributes["x"] = x-10
            text.text = field

            ty = base_line - (dh / 2)

            if count == 0
              i -= dh
            else
              ty -= i
            end

            text.attributes["y"] = ty
            
            i += dh
            count += 1
          end
        end

        dx = scale_range / scale_division
        scale_division_height = w.to_f / dx
        dx = scale_division_height.to_i
        count = 0
        y_value = min_scale_value
        stagger_count = 0
        if show_x_labels
          while (dx * count) < w
            text = root.add_element( "text", {
              "x" => x + (dx * count),
              "y" => base_line + 15,
              "class" => "xAxisLabels"
            })
            if scale_integers
              text.text = y_value.to_i
            else
              text.text = (y_value * 10).to_i / 10.0
            end
            if count != 0
              p1 = x + (dx * count)
              root.add_element( "path", {
                "d" => "M#{p1} #{base_line} V#{y}",
                "class" => "guideLines"
              });
              text.attributes["style"] = "text-anchor: middle;"
              if stagger_count == 2
                stagger_count = 0
              else
                text.attributes["y"] = base_line + 15 + stagger
                root.add_element( "path", {
                  "d" => "M#{p1} #{base_line}, v#{stagger}",
                  "class" => "staggerGuideLine"
                })
              end
            end
            y_value = y_value + scale_division
            count += 1
            stagger_count += 1
          end
        end

        if show_x_title 
          y_xtitle = show_x_labels ? 35 : 15
          root.add_element( "text", {
            "x" => (w / 2) + x,
            "y" => h + y + y_xtitle + stagger,
            "class" => "xAxisTitle"
          }).text = y_title
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

        bargap = bar_gap ? 10 : 0

        bar_width = dh - bargap
        divider = dx / scale_division

        xcount = 0

        subbar_height = bar_width
        subbar_height /= @data.length if stack == :side
        @config[:fields].each_index { |i|
          dcount = 1
          for dataset in @data
            data_val = dataset[:data][i]
            temp_y = base_line - (dh * xcount) - dh
            temp_x = x + (data_val * divider)
            temp_y += (dcount - 1) * subbar_height if stack == :side
            root.add_element( "path", {
              "d" => "M#{x} #{temp_y} H#{temp_x} v#{subbar_height} H#{x} Z",
              "class" => "fill#{dcount}"
            })
            if show_data_values
              root.add_element( "text", {
                "x" => temp_x + 5,
                "y" => temp_y + (dh / 2)-(stack==:side ? subbar_height/2 : 0),
                "class" => "dataPointLabel",
                "style" => "text-anchor: start;"
              }).text = data_val
            end
            dcount += 1
          end
          xcount += 1
        }

        key_box_size = 12
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
          y_key = base_line + 20 if show_x_labels
          y_key = base_line + 25 if show_x_title

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
    end
  end
end
