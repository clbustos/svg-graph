module SVG
module Graph
  VERSION = '1.0.3'
	autoload(:Bar, 'SVG/Graph/Bar')
	autoload(:BarBase, 'SVG/Graph/BarBase')
	autoload(:BarHorizontal, 'SVG/Graph/BarHorizontal')
	autoload(:Line, 'SVG/Graph/Line')
	autoload(:Pie, 'SVG/Graph/Pie')
	autoload(:Plot, 'SVG/Graph/Plot')
	autoload(:Schedule, 'SVG/Graph/Schedule')
	autoload(:TimeSeries, 'SVG/Graph/TimeSeries')
  autoload(:DataPoint, 'SVG/Graph/data_point')
end
end
