module Constants
  COMMANDS_WITH_FILE_TO_BE_CONVERTED = %w(input include).map(&:freeze).freeze
  COMMANDS_WITH_STRING_TO_BE_IGNORED = %w(includegraphics label ref).map(&:freeze).freeze

  ADDITIONAL_EXTENSION = '.mod.tex'.freeze
  USEPACKAGE_OTF = '\\\\usepackage\{otf\}'.freeze
  BEGIN_DOCUMENT = '\\\\begin\{document\}'.freeze
end
