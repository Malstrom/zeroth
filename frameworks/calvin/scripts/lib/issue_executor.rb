# frozen_string_literal: true
# Orchestratore principale per una singola issue.
# Sequenza: costruisce contesto → prompt → chiama Mistral → (per ora solo logga) → termina.

module Calvin
  class IssueExecutor
    def initialize(issue, github)
      @issue       = issue
      @github      = github
      @prompt_file = "/tmp/calvin_prompt_#{issue.number}.txt"
    end

    def run
      @github.post_status(@issue, "⏳ processing (Mistral only test)...")

      # Costruisce contesto da .calvin/ e assembla il prompt
      context = ContextBuilder.build(@issue)
      prompt  = PromptBuilder.build(@issue, context)
      File.write(@prompt_file, prompt)

      # Chiama Mistral direttamente e logga la risposta
      client   = MistralClient.new
      response = client.complete(prompt)

      LOG.info "Mistral response (truncated): #{response&.slice(0, 400)}"
      @github.post_status(@issue, "✅ Mistral responded:\n\n```\n#{response&.slice(0, 400)}\n```")
    rescue StandardError => e
      @github.post_status(@issue, "🚫 Mistral error\n\n```\n#{e.message}\n```")
      raise
    ensure
      FileUtils.rm_f(@prompt_file)
    end
  end
end
