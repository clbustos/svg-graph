begin
  require 'zlib'
  @@__have_zlib = true
rescue
  @@__have_zlib = false
end
=begin
= SVG::Graph - Base object for generating SVG Graphs

== SYNOPSIS

  module SVG::Graph::Graph_Type
    include SVG::Graph

    def set_defaults
      default = { 'keys' => 'value }
      default.each { |key, value|
        this.config[ key ] = value
      }
    end

    def get_template
      template = 'set the template'
      return template
    end

    def _init
      # any testing you want to do
    end
  end
  
In your script...
  
  require 'SVG/Graph/Graph_Type'

  width = 500
  height = 300
  fields = %w{ field_1 field_2 field_3 )

  graph = SVG::Graph::Graph_Type.new( {
    :fields => fields,
    # ... other config options
    :height => height
  })

  data = [ 23, 56, 32 ]

  graph.add_data( {
    :data => data,
    :title => 'Sales 2002'
  })

  config_value = graph.config_option
  graph.config_option = config_value

  graph.compress = true

  print "Content-type: image/svg+xml\r\n"
  print graph.burn

== DESCRIPTION

This package should be used as a base for creating SVG graphs.

See SVG::TT::Graph::Line for an example.

=end
module SVG
  module Graph
    class Graph
      VERSION = '0.06'

      def initialize( config )
        @config = config

        init if methods.include? "init"
        set_defaults if methods.include? "set_defaults"

        config.each { |key, value|
          self.send( key.to_s+"=", value ) if methods.include? key.to_s
        }
      end


      # This method allows you do add data to the graph object.
      # It can be called several times to add more data sets in.
      #
      #   data_sales_02 = [12, 45, 21];
      #   
      #   graph.add_data({
      #     :data => data_sales_02,
      #     :title => 'Sales 2002'
      #   })
      def add_data conf
        @data = [] unless @data

        if conf[:data] and conf[:data].kind_of? Array
          @data << conf
        else
          raise "No data provided by #{conf.inspect}"
        end
      end


      # This method removes all data from the object so that you can
      # reuse it to create a new graph but with the same config options.
      #
      #   graph.clear_data
      def clear_data 
        @data = []
      end


      # This method processes the template with the data and
      # config which has been set and returns the resulting SVG.
      #
      # This method will croak unless at least one data set has
      # been added to the graph object.
      #
      #   print graph.burn
      def burn
        raise "No data available" unless @data.size > 0
        
        calculations if methods.include? 'calculations'

        raise "#{self.class.name} must have a "+
          "get_svg method." unless methods.include?("get_svg")

        data = get_svg

        if @config[:compress]
          if @@__have_zlib
            inp, out = IO.pipe
            gz = Zlib::GzipWriter.new( out )
            gz.write data
            gz.close
            data = inp.read
          else
            data << "<!-- Ruby Zlib not available for SVGZ -->";
          end
        end
        
        return data
      end

      # Calculate a scaling range and divisions to be aesthetically pleasing
      # Parameters:: value range
      # Returns:: [revised range, division size, division precision]
      def range_calc(value, range)
        value = range
        division = 0
        max = 0
        count = 0
        
        if value == 0
          division = 0.2
          max = 1
          return [max, division, 1]
        end

        if value < 1
          while value < 1
            value *= 10
            count += 1
          end
          division = 1
          count.downto(0) { division /= 10 }
          max = (range.to_f / division).ceil * division
        else
          while value > 10
            value /= 10
            count += 1
          end
          division = 1
          count.downto(0) { division *= 10 }
          max = (range.to_f / division).ceil * division
        end

        if (max / division) <= 2
          division /= 5
          max = (range.to_f / division).ceil * division
        elsif (max / division) <= 5
          division /= 2 
          max = (range.to_f / division).ceil * division
        end
          
        if division >= 1
          count = 0
        else
          count = division.to_s.length - 2
        end
        
        return [max, division, count]
      end


      # Returns true if config value exists, is defined and not ''
      def is_valid_config name
        @config[name] and @config[name].length > 0
      end


      # This object provides autoload methods for all config
      # options defined in the set_defaults method within the
      # inheriting object.
      #
      # See the SVG::TT::Graph::GRAPH_TYPE documentation for a list.
      #
      #    value = graph.method()
      #    graph.method = value;
    end
  end
end
