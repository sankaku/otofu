require 'lib/constants.rb'

module TexCommandSearcher
  include Constants
  def regex_for_specific_commands(cmd)
    Regexp.new("(?<!\\\\)\\\\#{cmd}(?!\\w)[^\{]*\{(.*?)\}")
  end

  # Return the path corresponding to 'cmd',
  # the command_part(like '\cmd[...]{path}')
  # and after_command_part( = line_beginning_with_cmd - command_part).
  def parse_command_part(line_beginning_with_cmd, cmd)
    line_beginning_with_cmd =~ regex_for_specific_commands(cmd)
    path = Regexp.last_match(1)
    command_part = $&
    after_command_part = $'
    return path, command_part, after_command_part
  end

  # Return the first command and the index in the 'line'.
  def search_first_command(line)
    cmd_index_hash = {}
    (COMMANDS_WITH_STRING_TO_BE_IGNORED + COMMANDS_WITH_FILE_TO_BE_CONVERTED).each do |cmd|
      index = index_first_command(line, cmd)
      cmd_index_hash[cmd] = index unless index.nil?
    end
    return nil if cmd_index_hash.empty?
    first_command_and_index = get_min_value_element(cmd_index_hash)
    { command: first_command_and_index[0], index: first_command_and_index[1] }
  end

  def index_first_command(line, cmd)
    line.index(regex_for_specific_commands(cmd))
  end

  # Find the key-value pair having the minimum value of the 'hash',
  # and return [ key, value ] as an array.
  def get_min_value_element(hash)
    min_array = hash.min { |(_, v1), (_, v2)| v1 <=> v2 }
    unless hash.values.count { |i| i == min_array[1] } == 1
      raise "[Error] get_min_value_element(#{hash}) error. Maybe a bug."
    end
    min_array
  end
end
