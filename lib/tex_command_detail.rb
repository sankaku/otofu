require 'lib/constants.rb'


module TexCommandDetail
  include Constants

  def additional_extension_end_with_tex?
    ADDITIONAL_EXTENSION.split('.')[-1] == 'tex'
  end

  def referenced_filename_without_tex(fullpath, filename)
    unless additional_extension_end_with_tex?
      puts (<<-'EOF')
[Error] If you use the command 'include' or 'input'
  without the extension '.tex' in filepath extension,
  'ADDITIONAL_EXTENSION' must be end with '.tex'.
EOF
      exit
    end
    real_fullpath = fullpath + '.tex'
    path_after_command = filename + '.tex' + ADDITIONAL_EXTENSION.sub(/\.tex$/, '')
    return real_fullpath, path_after_command
  end

  def referenced_filename_with_tex(fullpath, filename)
    real_fullpath = fullpath
    path_after_command = filename + ADDITIONAL_EXTENSION
    return real_fullpath, path_after_command
  end

  # The real filename in '\input{filename.ex.te.n.sion}'
  # is 'filename.ex.te.n.sion' or 'filename.ex.te.n.sion.tex'
  # because of the rule of TeX.
  # So it must be choosed which filename is right before conversion.
  def referenced_filename(fullpath, path)
    file_exists_with_tex = File.exist?(fullpath)
    file_exists_without_tex = File.exist?(fullpath + '.tex')

    if file_exists_with_tex && file_exists_without_tex
      raise "Cannot choose the right filename in \'input\': #{fullpath}.
            Please remove or rename the non-referenced file(#{fullpath} or #{fullpath}.tex)."
    end
    return referenced_filename_with_tex(fullpath, path) if file_exists_with_tex
    return referenced_filename_without_tex(fullpath, path) if file_exists_without_tex
    raise "Cannot find the referenced file: #{fullpath}"
  end

  def remove_comment_from_line(line)
    return line.sub(/(?<!\\)%.*$/, '')
  end
end
