$: << File.dirname(__FILE__) + '/../lib'
require "test/unit"
require "svggraph"

class TestSvgGraph < Test::Unit::TestCase
    def test_bar_line_and_pie
        fields = %w(Jan Feb Mar);
        data_sales_02 = [12, 45, 21]
        [SVG::Graph::Bar, SVG::Graph::BarHorizontal, SVG::Graph::Line, SVG::Graph::Pie].each do 
            |klass|
            graph = klass.new(
            :height => 500,
            :width => 300,
            :fields => fields
            )
            graph.add_data(
            :data => data_sales_02,
            :title => 'Sales 2002'
            )
            out=graph.burn
            assert(out=~/Created with SVG::Graph/)
        end
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
    assert_match(/path class='line1' d='M.* L.*'/, out)
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
end
