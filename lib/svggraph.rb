module SVG
module Graph
  
  VERSION = '0.6.2'
  ORIGINAL_VERSION='0.6.1'
	autoload(:Bar, 'SVG/Graph/Bar')
	autoload(:BarBase, 'SVG/Graph/BarBase')
	autoload(:BarHorizontal, 'SVG/Graph/BarHorizontal')
	autoload(:Line, 'SVG/Graph/Line')
	autoload(:Pie, 'SVG/Graph/Pie')
	autoload(:Plot, 'SVG/Graph/Plot')
	autoload(:Schedule, 'SVG/Graph/Schedule')
	autoload(:TimeSeries, 'SVG/Graph/TimeSeries')
end
end
