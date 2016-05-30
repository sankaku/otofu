require 'lib/constants.rb'
require 'lib/file_utility.rb'
require 'lib/line_converter.rb'

class FileConverter
  include Constants, FileUtility

  def initialize(filename)
    @files_to_be_converted = []
    @absolute_path_of_file = File.expand_path(filename)
  end

  def convert
    out_filename = prepare_output_file
    return if out_filename.nil?

    buf = ''
    buffer_converted_file(buf, @absolute_path_of_file)
    make_sure_usepackage_otf(buf)
    flush_buffer_to_file(buf, out_filename)

    convert_recursively
  end

  def add_files_to_be_converted(fullpath)
    @files_to_be_converted << fullpath
  end

  def get_absolute_path(filename)
    current_directory = File.dirname(@absolute_path_of_file)
    File.expand_path(filename, current_directory)
  end

  private

  def prepare_output_file
    unless File.exist?(@absolute_path_of_file)
      puts  "[Error] Cannot find the file \'#{@absolute_path_of_file}.\'"
      return nil
    end

    out_filename = @absolute_path_of_file + ADDITIONAL_EXTENSION
    delete_file(out_filename)
    out_filename
  end

  def buffer_converted_file(buf, filename)
    File.open(filename, 'r:utf-8') do |f|
      f.each_line do |l|
        buf << LineConverter.new(self).convert_line(l)
      end
    end
  end

  def convert_recursively
    return if @files_to_be_converted.nil?
    @files_to_be_converted.uniq.each { |f| FileConverter.new(f).convert }
  end

  # If there is no 'USEPACKAGE_OTF' in the preamble of 'buf',
  # insert it right above the 'BEGIN_DOCUMENT.'
  # If there is no 'BEGIN_DOCUMENT' in 'buf',
  # this insertion is not performed because the 'buf' must be entirely the body.
  def make_sure_usepackage_otf(buf)
    has_already_written, line_begin_document = search_usepackage_otf(buf)
    return if has_already_written == true
    return if line_begin_document.nil?
    usepackage_otf_string = USEPACKAGE_OTF.gsub(/\\([\{\}])/, '\1').sub('\\\\', '\\')
    buf.replace(buf.lines.insert(line_begin_document.to_i, usepackage_otf_string + "\n").join)
  end

  def search_usepackage_otf(buf)
    buf.lines.each_with_index do |line, index|
      return true, nil unless (line =~ /^#{USEPACKAGE_OTF}/).nil?
      return false, index unless (line =~ /^#{BEGIN_DOCUMENT}/).nil?
    end
    return false, nil
  end
end
