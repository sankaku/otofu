require 'test/unit'

$: << File.dirname('lib')
require 'lib/file_converter.rb'
require 'lib/line_converter.rb'
require 'lib/tex_command_searcher.rb'

class TestSample < Test::Unit::TestCase
  def setup
    @fc = FileConverter.new('')
    @lc = LineConverter.new(@fc)
  end

  def test_parse_command_part
    line = '\\includegraphics[bar]{てすと.eps}test\\input{あいうえお}a\\include{試験.tex}b\\includegraphics{}cde\\ref{zzz}fg'
    expected = ['てすと.eps', '\\includegraphics[bar]{てすと.eps}', 'test\\input{あいうえお}a\\include{試験.tex}b\\includegraphics{}cde\\ref{zzz}fg']

    path, command_part, after_command_part = @lc.parse_command_part(line, 'includegraphics')
    actual = [path, command_part, after_command_part]

    assert_equal(expected, actual)
  end

  def test_search_first_command
    line = 'foobar\\includegraphics[bar]{てすと.eps}test\\input{あいうえお}a\\include{試験.tex}b\\includegraphics{}cde\\ref{zzz}fg'
    expected = { command: 'includegraphics', index: 6 }

    actual = @lc.search_first_command(line)

    assert_equal(expected, actual)
  end

  def test_search_first_command_escape
    line = 'foobar\\\\includegraphics[bar]{てすと.eps}test\\\\input{あいうえお}a\\include{試験.tex}b\\includegraphics{}cde\\ref{zzz}fg'
    expected = { command: 'include', index: 56 }

    actual = @lc.search_first_command(line)

    assert_equal(expected, actual)
  end

  def test_index_first_commmand
    line = 'foobar\\includegraphics[bar]{てすと.eps}test\\input{あいうえお}a\\include{試験.tex}b\\includegraphics{}cde\\ref{zzz}fg'
    expected = 54

    actual = @lc.index_first_command(line, 'include')

    assert_equal(expected, actual)
  end

  def test_index_first_commmand_escape
    line = 'foobar\\\\includegraphics[bar]{てすと.eps}test\\\\input{あいうえお}a\\include{試験.tex}b\\includegraphics{}cde\\ref{zzz}fg'
    expected = 73

    actual = @lc.index_first_command(line, 'includegraphics')

    assert_equal(expected, actual)
  end

  def test_get_min_value_element
    hash = { 'a' => 3, 'b' => 2, 'c' => 5, 'd' => 0, 'e' => 10 }
    expected = ['d', 0]

    actual = @lc.get_min_value_element(hash)

    assert_equal(expected, actual)
  end

  def test_get_min_value_element_multi_min
    hash = { 'a' => 0, 'b' => 2, 'c' => 0, 'd' => 0, 'e' => 10 }

    assert_raise { @lc.get_min_value_element(hash) }
  end
end

