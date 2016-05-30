require 'test/unit'

$: << File.dirname('lib')
require 'lib/tex_command_detail.rb'
require 'lib/constants.rb'

class TexCommandDetailImpl
  include TexCommandDetail
end

class TestTexCommandDetail < Test::Unit::TestCase
  include Constants
  def setup
    @current_directory = File.expand_path('') + '/'
    @impl = TexCommandDetailImpl.new
  end


  def test_referenced_filename_without_tex
    filename = 'This/is/a/テスト/filename.ext'
    fullpath = @current_directory + filename
    filepath = fullpath + '.tex'
    filename_after_command = filename + '.tex' + ADDITIONAL_EXTENSION.sub(/\.tex$/, '')
    expected = [filepath, filename_after_command]

    actual_filepath, actual_filename_after_command = @impl.referenced_filename_without_tex(fullpath, filename)
    actual = [actual_filepath, actual_filename_after_command]

    assert_equal(expected, actual)
  end

  def test_referenced_filename_with_tex
    filename = 'This/is/a/テスト/filename.ext.tex'
    fullpath = @current_directory + filename
    filepath = fullpath
    filename_after_command = filename + ADDITIONAL_EXTENSION
    expected = [filepath, filename_after_command]

    actual_filepath, actual_filename_after_command = @impl.referenced_filename_with_tex(fullpath, filename)
    actual = [actual_filepath, actual_filename_after_command]

    assert_equal(expected, actual)
  end


  def test_referenced_filename_cannot_choose_filename
    filename = 'test/data/exceptional_filename.txt'

    assert_raise{ @impl.referenced_filename(filename) }
  end

  def test_referenced_filename_cannot_find_file
    filename = 'test/data/foobar'

    assert_raise{ @impl.referenced_filename(filename) }
  end

  def test_referenced_filename_with
    filename = 'test/data/test_file.tex'
    fullpath = @current_directory + filename
    real_filename = fullpath
    filename_after_command = filename + ADDITIONAL_EXTENSION
    expected = [real_filename, filename_after_command]

    actual_filepath, actual_filename_after_command = @impl.referenced_filename(fullpath, filename)
    actual = [actual_filepath, actual_filename_after_command]

    assert_equal(expected, actual)
  end


  def test_referenced_filename_without
    filename = 'test/data/test_file2.ext'
    fullpath = @current_directory + filename
    real_filename = fullpath + '.tex'
    filename_after_command = filename + '.tex' + ADDITIONAL_EXTENSION.sub(/\.tex$/, '')
    expected = [real_filename, filename_after_command]

    actual_filepath, actual_filename_after_command = @impl.referenced_filename(fullpath, filename)
    actual = [actual_filepath, actual_filename_after_command]

    assert_equal(expected, actual)
  end
  def test_remove_comment_from_line
    line = 'This is not a comment.% This is a comment.'
    expected = 'This is not a comment.'

    actual = @impl.remove_comment_from_line(line)

    assert_equal(expected, actual)
  end

  def test_remove_comment_from_line_escape
    line = 'This is not a comment.\%\%\%% This is a comment.'
    expected = 'This is not a comment.\%\%\%'

    actual = @impl.remove_comment_from_line(line)

    assert_equal(expected, actual)
  end
end
