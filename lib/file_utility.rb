module FileUtility

  def flush_buffer_to_file(buf, filename)
    File.open(filename, 'a:utf-8') do |f|
      f.write(buf)
    end
  end

  def delete_file(filename)
    File.delete(filename) if File.exist?(filename)
  end
end
