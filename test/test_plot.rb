$: << File.dirname(__FILE__) + '/../lib'
require "test/unit"
require "svggraph"
require "SVG/Graph/DataPoint"

class TestSvgGraphPlot < Test::Unit::TestCase
  def setup
    DataPoint.reset_shape_criteria
  end
  def teardown
    DataPoint.reset_shape_criteria
  end
  def test_plot

      projection = [
       6, 11,    0, 5,   18, 7,   1, 11,   13, 9,   1, 2,   19, 0,   3, 13,
       7, 9
      ]
      actual = [
       0, 18,    8, 15,    9, 4,   18, 14,   10, 2,   11, 6,  14, 12,
       15, 6,   4, 17,   2, 12
      ]

      graph = SVG::Graph::Plot.new({
      :height => 500,
          :width => 300,
       :key => true,
       :scale_x_integers => true,
       :scale_y_integerrs => true,
      })

      graph.add_data({
      :data => projection,
        :title => 'Projected',
      })

      graph.add_data({
      :data => actual,
        :title => 'Actual',
      })

      out=graph.burn()
      assert(out=~/Created with SVG::Graph/)
  end
  def test_default_plot_emits_polyline_connecting_data_points
    actual = [
      0, 18,    8, 15,    9, 4,   18, 14,   10, 2,   11, 6,  14, 12,
      15, 6,   4, 17,   2, 12
    ]

    graph = SVG::Graph::Plot.new({
      :height => 500,
      :width => 300,
      :key => true,
      :scale_x_integers => true,
      :scale_y_integerrs => true,
    })

    graph.add_data({
      :data => actual,
      :title => 'Actual',
    })
    out=graph.burn()
    assert_match(/path.*class='line1'/, out)
  end

  def test_disabling_show_lines_does_not_emit_polyline_connecting_data_points
    actual = [
      0, 18,    8, 15,    9, 4,   18, 14,   10, 2,   11, 6,  14, 12,
      15, 6,   4, 17,   2, 12
    ]

    graph = SVG::Graph::Plot.new({
      :height => 500,
      :width => 300,
      :key => true,
      :scale_x_integers => true,
      :scale_y_integers => true,
      :show_lines => false,
    })

    graph.add_data({
      :data => actual,
      :title => 'Actual',
    })

    out=graph.burn()
    assert_no_match(/path class='line1' d='M.* L.*'/, out)
  end

  def test_popup_values_round_to_integer_by_default_in_popups
    actual = [
      0.1, 18,    8.55, 15.1234,    9.09876765, 4,
    ]

    graph = SVG::Graph::Plot.new({
      :height => 500,
      :width => 300,
      :key => true,
      :scale_x_integers => true,
      :scale_y_integers => true,
      :add_popups => true,
    })

    graph.add_data({
      :data => actual,
      :title => 'Actual',
    })

    out=graph.burn()
    assert_no_match(/\(0.1, 18\)/, out)
    assert_match(/\(0, 18\)/, out)
    assert_no_match(/\(8.55, 15.1234\)/, out)
    assert_match(/\(8, 15\)/, out)
    assert_no_match(/\(9.09876765, 4\)/, out)
    assert_match(/\(9, 4\)/, out)
  end

  def test_do_not_round_popup_values_shows_decimal_values_in_popups
    actual = [
      0.1, 18,    8.55, 15.1234,    9.09876765, 4,
    ]

    graph = SVG::Graph::Plot.new({
      :height => 500,
      :width => 300,
      :key => true,
      :scale_x_integers => true,
      :scale_y_integers => true,
      :add_popups => true,
      :round_popups => false,
    })

    graph.add_data({
      :data => actual,
      :title => 'Actual',
    })

    out=graph.burn()
    assert_match(/\(0.1, 18\)/, out)
    assert_no_match(/\(0, 18\)/, out)
    assert_match(/\(8.55, 15.1234\)/, out)
    assert_no_match(/\(8, 15\)/, out)
    assert_match(/\(9.09876765, 4\)/, out)
    assert_no_match(/\(9, 4\)/, out)
  end

  def test_description_is_shown_in_popups_if_provided
    actual = [
      8.55, 15.1234,    9.09876765, 4,     0.1, 18,
    ]
    description = [
     'first',    'second',          'third',
    ]

    graph = SVG::Graph::Plot.new({
      :height => 500,
      :width => 300,
      :key => true,
      :scale_x_integers => true,
      :scale_y_integers => true,
      :add_popups => true,
      :round_popups => false,
    })

    graph.add_data({
      :data => actual,
      :title => 'Actual',
      :description => description,
    })

    out=graph.burn()
    assert_match(/\(8.55, 15.1234, first\)/, out)
    assert_no_match(/\(8.55, 15.1234\)/, out)
    assert_match(/\(9.09876765, 4, second\)/, out)
    assert_no_match(/\(9.09876765, 4\)/, out)
    assert_match(/\(0.1, 18, third\)/, out)
    assert_no_match(/\(0.1, 18\)/, out)
  end
  def test_combine_different_shapes_based_on_description
    actual = [
     8.55, 15.1234,         9.09876765, 4,                  2.1, 18,
    ]
    description = [
     'one is a circle',     'two is a rectangle',           'three is a rectangle with strikethrough',
    ]

    DataPoint.configure_shape_criteria(
      [/^t.*/, lambda{|x,y,line| ['polygon', {
          "points" => "#{x-1.5},#{y+2.5} #{x+1.5},#{y+2.5} #{x+1.5},#{y-2.5} #{x-1.5},#{y-2.5}",
          "class" => "dataPoint#{line}"
        }]
      }],
      [/^three.*/, lambda{|x,y,line| ['line', {
          "x1" => "#{x-4}",
          "y1" => y.to_s,
          "x2" => "#{x+4}",
          "y2" => y.to_s,
          "class" => "axis"
        }]
      }]
    )
    graph = SVG::Graph::Plot.new({
      :height => 500,
      :width => 300,
      :key => true,
      :scale_x_integers => true,
      :scale_y_integers => true,
      :add_popups => true,
      :round_popups => false,
    })

    graph.add_data({
      :data => actual,
      :title => 'Actual',
      :description => description,
    })

    out=graph.burn()
    assert_match(/polygon.*points/, out)
    assert_match(/line.*axis/, out)
  end
  def test_popup_radius_is_10_by_default
    actual = [
     1, 1,    5, 5,     10, 10,
    ]
    description = [
     'first',    'second',          'third',
    ]

    graph = SVG::Graph::Plot.new({
      :height => 500,
      :width => 300,
      :key => true,
      :scale_x_integers => true,
      :scale_y_integers => true,
      :add_popups => true,
      :round_popups => false,
    })

    graph.add_data({
      :data => actual,
      :title => 'Actual',
      :description => description,
    })

    out=graph.burn()
    assert_match(/circle .*r='10'/, out)
    assert_match(/circle .*onmouseover=.*/, out)
    
  end
  def test_popup_radius_is_overridable
    actual = [
     1, 1,    5, 5,     10, 10,
    ]
    description = [
     'first',    'second',          'third',
    ]

    graph = SVG::Graph::Plot.new({
      :height => 500,
      :width => 300,
      :key => true,
      :scale_x_integers => true,
      :scale_y_integers => true,
      :add_popups => true,
      :round_popups => false,
      :popup_radius => 1.23
    })

    graph.add_data({
      :data => actual,
      :title => 'Actual',
      :description => description,
    })

    out=graph.burn()
    assert_match(/circle .*r='1.23'/, out)
    assert_match(/circle .*onmouseover=.*/, out)
    
  end
end
