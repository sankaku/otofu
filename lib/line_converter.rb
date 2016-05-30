require 'lib/constants.rb'
require 'lib/file_utility.rb'
require 'lib/tex_command_searcher.rb'
require 'lib/tex_command_detail.rb'

class LineConverter
  include Constants, TexCommandSearcher, FileUtility, TexCommandDetail

  def initialize(file_converter)
    @file_converter = file_converter
  end

  def convert_line(line)
    line = remove_comment_from_line(line)
    return '' if line.empty?

    first_command_and_index = search_first_command(line)
    return convert_line_primitively(line) if first_command_and_index.nil?

    buf, line_after_cmd = convert_until_command_part(line, first_command_and_index)
    return buf if line_after_cmd.nil?
    buf << convert_line(line_after_cmd)
  end

  private

  # Convert until the end
  # of the command part (like '\cmd[...]{path}').
  def convert_until_command_part(line, cmd_with_index)
    buf, line_beginning_with_cmd = convert_before_command_part(line, cmd_with_index)

    cmd = cmd_with_index[:command]
    path, command_part, after_command_part = parse_command_part(line_beginning_with_cmd, cmd)
    path_manager(cmd, path, command_part)
    buf << command_part
    return buf, after_command_part
  end

  def path_manager(cmd, path, command_part)
    return unless COMMANDS_WITH_FILE_TO_BE_CONVERTED.include?(cmd)
    fullpath = @file_converter.get_absolute_path(path)
    real_filename, filename_after_command = referenced_filename(fullpath, path)
    @file_converter.add_files_to_be_converted(real_filename)
    if command_part.scan(path).length != 1
      raise "[Error] path_manager error. Cannot find the file path.\n[ #{line} ]"
    end
    command_part.sub!(path, filename_after_command)
  end

  # Convert until just before the beginning
  # of the command part (line '\cmd[...]{path}').
  def convert_before_command_part(line, cmd_with_index)
    buf = ''
    index = cmd_with_index[:index]
    line_beginning_with_cmd = line.slice(index..-1)
    buf << convert_line_primitively(line.slice(0..index - 1)) unless index == 0
    return buf, line_beginning_with_cmd
  end

  def convert_char(c)
    max_ascii_code = 127
    hexadecimal = 16

    return c if c.ord <= max_ascii_code
    '\\UTF{' + c.ord.to_s(hexadecimal) + '}'
  end

  def convert_line_primitively(line)
    buf = ''
    line.each_char { |c| buf << convert_char(c) }
    buf
  end
end
