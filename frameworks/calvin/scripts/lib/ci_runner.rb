# frozen_string_literal: true
# Esegue bin/rails ci nel repo target e cattura l'output.
# Dir.pwd deve essere la root del repo Rails (target/).
#
# Uso:
#   result = Calvin::CiRunner.new.run
#   result.passed  # => true / false
#   result.output  # => String con stdout+stderr combinati

require "open3"

module Calvin
  class CiRunner
    # Timeout in secondi per l'intera suite CI.
    # bin/rails ci include rubocop + brakeman + minitest.
    TIMEOUT = 600

    CiResult = Data.define(:passed, :output)

    def run
      Calvin::LOG.info "Running bin/rails ci..."

      ci_path = File.join(Dir.pwd, "backend", "api")
      cmd     = ["bin/rails", "ci"]

      output, status = with_timeout(TIMEOUT) do
        Open3.capture2e(*cmd, chdir: ci_path)
      end

      passed = status.success?
      Calvin::LOG.info "CI #{passed ? 'passed ✅' : 'failed ❌'}"
      Calvin::LOG.info output.slice(0, 2_000) unless passed

      CiResult.new(passed: passed, output: output)
    rescue Timeout::Error
      Calvin::LOG.error "CI timed out after #{TIMEOUT}s"
      CiResult.new(passed: false, output: "CI timed out after #{TIMEOUT}s")
    end

    private

    def with_timeout(seconds, &block)
      Timeout.timeout(seconds, &block)
    end
  end
end
