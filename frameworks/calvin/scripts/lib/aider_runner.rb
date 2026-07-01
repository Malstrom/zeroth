# frozen_string_literal: true
# Esegue aider con il prompt file dato e una lista opzionale di file da includere nel contesto.
# Provider fisso: Mistral Codestral.
# In caso di errore ritorna { success: false, reason: ... }.

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
        aider --yes --no-auto-commits --no-pretty
        --model #{MODEL}
        --message-file #{@prompt_file}
      ]

      # Aggiunge i file di contesto: aider li legge e può modificarli
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
