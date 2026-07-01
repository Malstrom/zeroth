# frozen_string_literal: true
# Esegue aider con il prompt file dato.
# Provider fisso: Mistral Codestral.
# In caso di errore ritorna { success: false, reason: ... }.

module Calvin
  class AiderRunner
    MODEL = "mistral/codestral-latest"

    def self.run(prompt_file) = new(prompt_file).run

    def initialize(prompt_file)
      @prompt_file = prompt_file
    end

    def run
      LOG.info "running aider with #{MODEL}"

      # Salva lo SHA corrente per poter fare reset in caso di fallimento
      head_sha = `git rev-parse HEAD`.strip

      result = call_aider

      if result[:success]
        LOG.info "aider succeeded"
        { success: true, model: MODEL }
      else
        LOG.warn "aider failed: #{result[:output].lines.last(3).join}"
        # Ripristina il repo allo stato pre-aider
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
