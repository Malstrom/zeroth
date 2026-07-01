# frozen_string_literal: true
# Esegue aider in modalità chat con --message-file.
# I file da creare/modificare vengono passati esplicitamente nel prompt (via PromptBuilder)
# e come --file per quelli già esistenti.
# --architect è escluso: blocca in CI per mancanza di terminal.
# Provider fisso: Mistral Codestral.

module Calvin
  class AiderRunner
    MODEL = "mistral/codestral-latest"

    def self.run(prompt_file, files: []) = new(prompt_file, files:).run

    def initialize(prompt_file, files: [])
      @prompt_file = prompt_file
      @files       = files
    end

    def run
      LOG.info "running aider with #{MODEL} (#{@files.size} context files)"

      head_sha = `git rev-parse HEAD`.strip
      result   = call_aider

      if result[:success]
        LOG.info "aider succeeded"
        { success: true, model: MODEL }
      else
        LOG.warn "aider failed: #{result[:output].lines.last(5).join}"
        `git reset --hard #{head_sha}`
        `git clean -fd`
        { success: false, reason: result[:output] }
      end
    end

    private

    def call_aider
      cmd = %W[
        aider
        --yes
        --no-auto-commits
        --no-pretty
        --no-fancy-input
        --model #{MODEL}
        --message-file #{@prompt_file}
      ]

      @files.each { |f| cmd += ["--file", f] }

      stdout, stderr, status = Open3.capture3(*cmd)
      output = stdout + stderr
      {
        success:      status.success? && !output.match?(/error|traceback/i),
        rate_limited: output.match?(/429|rate.?limit/i),
        output:       output
      }
    end
  end
end
