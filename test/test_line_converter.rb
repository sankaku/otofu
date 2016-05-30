require 'test/unit'

$: << File.dirname('lib')
require 'lib/file_converter.rb'
require 'lib/line_converter.rb'
require 'lib/constants.rb'
require 'lib/tex_command_searcher.rb'


class TestSample < Test::Unit::TestCase
  include Constants

  def setup
    # @fc = FileConverter.new('')
    @fc = FileConverter.new(File.dirname(__FILE__) + '/foo.tex')
    @lc = LineConverter.new(@fc)
  end

  def test_convert_char_non_ascii
    c = '髙'
    expected = '\\UTF{9ad9}'

    actual = @lc.send(:convert_char, c)

    assert_equal(expected, actual)
  end

  def test_convert_char_ascii
    c = 'z'
    expected = 'z'

    actual = @lc.send(:convert_char, c)

    assert_equal(expected, actual)
  end

  def test_convert_line_primitively
    line = 'abcdeVWXYZ012345あいうえお'
    expected = 'abcdeVWXYZ012345\\UTF{3042}\\UTF{3044}\\UTF{3046}\\UTF{3048}\\UTF{304a}'

    actual = @lc.send(:convert_line_primitively, line)

    assert_equal(expected, actual)
  end

  def test_convert_before_command_part
    line = 'abcdeVWXYZ012345あいうえお\\includegraphics[bar]{てすと.eps}test\\input{data/あいうえお}a\\include{data/試験}b\\includegraphics{}cde\\ref{zzz}fg'
    cmd_with_index = { command: 'includegraphics', index: 21 }
    expected = ['abcdeVWXYZ012345\\UTF{3042}\\UTF{3044}\\UTF{3046}\\UTF{3048}\\UTF{304a}', '\\includegraphics[bar]{てすと.eps}test\\input{data/あいうえお}a\\include{data/試験}b\\includegraphics{}cde\\ref{zzz}fg']

    actual = @lc.send(:convert_before_command_part, line, cmd_with_index)

    assert_equal(expected, actual)
  end

  def test_convert_until_command_part_includegraphics
    line = 'abcdeVWXYZ012345あいうえお\\includegraphics[bar]{てすと.eps}test\\input{data/あいうえお}a\\include{data/試験}b\\includegraphics{}cde\\ref{zzz}fg'
    cmd_with_index = { command: 'includegraphics', index: 21 }
    expected = ['abcdeVWXYZ012345\\UTF{3042}\\UTF{3044}\\UTF{3046}\\UTF{3048}\\UTF{304a}\\includegraphics[bar]{てすと.eps}', 'test\\input{data/あいうえお}a\\include{data/試験}b\\includegraphics{}cde\\ref{zzz}fg']

    buf, after_cmd = @lc.send(:convert_until_command_part, line, cmd_with_index)
    actual = [buf, after_cmd]

    assert_equal(expected, actual)
  end

  def test_convert_until_command_part_include
    line = 'abcdeVWXYZ012345あいうえお\\\\includegraphics[bar]{てすと.eps}test\\\\input{data/あいうえお}a\\include{data/試験}b\\includegraphics{}cde\\ref{zzz}fg'
    cmd_with_index = { command: 'include', index: 76 }
    expected = ['abcdeVWXYZ012345\\UTF{3042}\\UTF{3044}\\UTF{3046}\\UTF{3048}\\UTF{304a}\\\\includegraphics[bar]{\\UTF{3066}\\UTF{3059}\\UTF{3068}.eps}test\\\\input{data/\\UTF{3042}\\UTF{3044}\\UTF{3046}\\UTF{3048}\\UTF{304a}}a\\include{data/試験.tex.mod}' , 'b\\includegraphics{}cde\\ref{zzz}fg']

    buf, after_cmd = @lc.send(:convert_until_command_part, line, cmd_with_index)
    actual = [buf, after_cmd]

    assert_equal(expected, actual)
  end

  def test_path_manager
    cmd = 'include'
    path = './data/test_file2.ext'
    command_part = "\\#{cmd}{#{path}}"
    expected =  "\\#{cmd}{#{path}.tex#{ADDITIONAL_EXTENSION.sub(/\.tex$/, '')}}"

    @lc.send(:path_manager, cmd, path, command_part)
    actual = command_part

    assert_equal(expected, actual)
  end

  def test_path_manager_no_add
    cmd = 'includegraphics'
    path = './foo/bar/baz.eps'
    command_part = "\\#{cmd}{#{path}}"
    expected =  "\\#{cmd}{#{path}}"

    @lc.send(:path_manager, cmd, path, command_part)
    actual = command_part

    assert_equal(expected, actual)
  end

  def test_convert_line
    line = 'abcdeVWXYZ012345あいうえお\\includegraphics[bar]{てすと.eps}test\\input{data/あいうえお.tex}a\\include{data/試験}b\\includegraphics{}cde\\ref{zzz}fg'
    expected = 'abcdeVWXYZ012345\\UTF{3042}\\UTF{3044}\\UTF{3046}\\UTF{3048}\\UTF{304a}\\includegraphics[bar]{てすと.eps}test\\input{data/あいうえお.tex.mod.tex}a\\include{data/試験.tex.mod}b\\includegraphics{}cde\\ref{zzz}fg'

    actual = @lc.convert_line(line)

    assert_equal(expected, actual)
  end
end

