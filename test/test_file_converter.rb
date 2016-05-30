require 'test/unit'

$: << File.dirname('lib')
require 'lib/file_converter.rb'
require 'lib/line_converter.rb'
require 'lib/tex_command_searcher.rb'

class TestSample < Test::Unit::TestCase
  def setup
    @fc = FileConverter.new('')
  end

  def test_search_usepackage_otf_no_otf
    buf = "\\documentclass[...]\n\\foo\n\n\n\\bar\n\\begin{document}\n\n\\baz"
    expected =  [false, 5]

    is_written, index = @fc.send(:search_usepackage_otf, buf)
    actual = [is_written, index]

    assert_equal(expected, actual)
  end

  def test_search_usepackage_otf_perfect_preamble
    buf = "\\documentclass[...]\n\\foo\n\n\\usepackage{otf}\n\\bar\n\\begin{document}\n\n\\baz"
    expected =  [true, nil]

    is_written, index = @fc.send(:search_usepackage_otf, buf)
    actual = [is_written, index]

    assert_equal(expected, actual)
  end

  def test_search_usepackage_otf_body
    buf = "\n\\foo\n\n\n\\bar\n\n\n\\baz"
    expected =  [false, nil]

    is_written, index = @fc.send(:search_usepackage_otf, buf)
    actual = [is_written, index]

    assert_equal(expected, actual)
  end

  def test_make_sure_usepackage_otf_no_otf
    buf = "\\documentclass[...]\n\\foo\n\n\n\\bar\n\\begin{document}\n\n\\baz"
    expected = "\\documentclass[...]\n\\foo\n\n\n\\bar\n\\usepackage{otf}\n\\begin{document}\n\n\\baz"

    actual = @fc.send(:make_sure_usepackage_otf, buf)

    assert_equal(expected, actual)
  end

  def test_make_sure_usepackage_otf_perfect_preamble
    buf = "\\documentclass[...]\n\\foo\n\n\\usepackage{otf}\n\\bar\n\\begin{document}\n\n\\baz"
    expected = "\\documentclass[...]\n\\foo\n\n\\usepackage{otf}\n\\bar\n\\begin{document}\n\n\\baz"

    @fc.send(:make_sure_usepackage_otf, buf)
    actual = buf

    assert_equal(expected, actual)
  end

  def test_make_sure_usepackage_otf_body
    buf = "\n\\foo\n\n\n\\bar\n\n\n\\baz"
    expected = "\n\\foo\n\n\n\\bar\n\n\n\\baz"

    @fc.send(:make_sure_usepackage_otf, buf)
    actual = buf

    assert_equal(expected, actual)
  end
end

