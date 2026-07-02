# frozen_string_literal: true
# Esegue solo i test Rails nel repo target e cattura l'output.
# Non usa bin/rails ci (che fa anche push) — chiama direttamente bundle exec rails test.
#
# Dir.pwd deve essere la root del repo clonato (target/).
#
# Uso:
#   result = Calvin::CiRunner.new.run
#   result.passed  # => true / false
#   result.output  # => String con stdout+stderr combinati

require "open3"
require "timeout"

module Calvin
  class CiRunner
    TIMEOUT = 300

    CiResult = Data.define(:passed, :output)

    def run
      Calvin::LOG.info "Running tests..."

      ci_path = File.join(Dir.pwd, "backend", "api")
      gemfile = File.join(ci_path, "Gemfile")
      cmd     = ["bundle", "exec", "rails", "test"]

      output, status = Timeout.timeout(TIMEOUT) do
        Open3.capture2e(
          { "BUNDLE_GEMFILE" => gemfile },
          *cmd,
          chdir: ci_path
        )
      end

      passed = status.success?
      Calvin::LOG.info "Tests #{passed ? 'passed ✅' : 'failed ❌'}"
      Calvin::LOG.info output.slice(0, 2_000) unless passed

      CiResult.new(passed: passed, output: output)
    rescue Timeout::Error
      Calvin::LOG.error "Tests timed out after #{TIMEOUT}s"
      CiResult.new(passed: false, output: "Tests timed out after #{TIMEOUT}s")
    end
  end
end
