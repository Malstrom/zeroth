# frozen_string_literal: true
# Scrive i file generati da Mistral nel working tree.
# Input: Array<{path:, content:}>
# Output: Array<String> — path dei file scritti

require "fileutils"

module Calvin
  class CodeWriter
    def self.write(files) = new(files).write

    def initialize(files)
      @files = files
    end

    def write
      written = []
      @files.each do |f|
        path = f[:path]
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, f[:content])
        LOG.info "wrote #{path} (#{f[:content].lines.count} lines)"
        written << path
      end
      written
    end
  end
end
