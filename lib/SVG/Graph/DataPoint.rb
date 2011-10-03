class DataPoint
  OVERLAY = "OVERLAY" unless defined?(OVERLAY)
  DEFAULT_SHAPE = lambda{|x,y,line| ["circle", {
          "cx" => x,
          "cy" => y,
          "r" => "2.5",
          "class" => "dataPoint#{line}"
        }]
      } unless defined? DEFAULT_SHAPE
  CRITERIA = [] unless defined? CRITERIA
  def DataPoint.configure_shape_criteria(*matchers)
    CRITERIA.push(*matchers)
  end
  def DataPoint.reset_shape_criteria
    CRITERIA.clear
  end

  def initialize(x, y, line)
    @x = x
    @y = y
    @line = line
  end
  def shape(description=nil)
    shapes = CRITERIA.select {|criteria|
      criteria.size == 2
    }.collect {|regexp, proc|
      proc.call(@x, @y, @line) if description =~ regexp
    }.compact
    shapes = [DEFAULT_SHAPE.call(@x, @y, @line)] if shapes.empty?

    overlays = CRITERIA.select { |criteria|
      criteria.last == OVERLAY
    }.collect { |regexp, proc|
      proc.call(@x, @y, @line) if description =~ regexp
    }.compact

    return shapes + overlays
  end
end
