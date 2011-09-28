$: << File.dirname(__FILE__) + '/../lib'
require "test/unit"
require "SVG/graph/data_point"

class DataPointTest < Test::Unit::TestCase
  def setup
    DataPoint.reset_shape_criteria
  end
  def teardown
    DataPoint.reset_shape_criteria
  end
  def test_default_shape_is_circle_with_2_point_5_radius
    assert_equal([['circle', {
        "cx" => 100.0,
        "cy" => 100.0,
        "r" => "2.5",
        "class" => "dataPoint1"
    }]], DataPoint.new(100.0, 100.0, 1).shape)
  end
  def test_default_shape_based_on_description_without_criteria_is_circle_with_2_point_5_radius
    assert_equal([['circle', {
        "cx" => 100.0,
        "cy" => 100.0,
        "r" => "2.5",
        "class" => "dataPoint1"
    }]], DataPoint.new(100.0, 100.0, 1).shape("description"))
  end
  def test_shape_for_matching_regular_expression_is_lambda_value
    DataPoint.configure_shape_criteria(
      [/angle/, lambda{|x,y,line| ['rect', {
          "x" => x,
          "y" => y,
          "width" => "5",
          "height" => "5",
          "class" => "dataPoint#{line}"
        }]
      }]
    )
    assert_equal([['rect', {
        "x" => 100.0,
        "y" => 50.0,
        "width" => "5",
        "height" => "5",
        "class" => "dataPoint2"
    }]], DataPoint.new(100.0, 50.0, 2).shape("rectangle"))
  end
  def test_multiple_criteria_generate_shapes_in_order
    DataPoint.configure_shape_criteria(
      [/3/, lambda{|x,y,line| "three" }],
      [/2/, lambda{|x,y,line| "two" }],
      [/1/, lambda{|x,y,line| "one" }]
    )
    assert_equal(["three", "two", "one"], DataPoint.new(100.0, 50.0, 2).shape("1 3 2"))
  end
  def test_overlay_match_is_last_and_does_not_prevent_default
    DataPoint.configure_shape_criteria(
      [/3/, lambda{|x,y,line| "three" }, DataPoint::OVERLAY]
    )
    default_circle = ['circle', {
        "cx" => 100.0,
        "cy" => 50.0,
        "r" => "2.5",
        "class" => "dataPoint2"
    }]
    assert_equal([default_circle, "three"], DataPoint.new(100.0, 50.0, 2).shape("1 3 2"))
  end
end