# frozen_string_literal: true
# Orchestratore principale per una singola issue.
# Sequenza: costruisce contesto → prompt → chiama Mistral → posta risposta completa sull'issue.

module Calvin
  class IssueExecutor
    def initialize(issue, github)
      @issue       = issue
      @github      = github
      @prompt_file = "/tmp/calvin_prompt_#{issue.number}.txt"
    end

    def run
      @github.post_status(@issue, "⏳ processing...")

      context = ContextBuilder.build(@issue)
      prompt  = PromptBuilder.build(@issue, context)
      File.write(@prompt_file, prompt)

      client   = MistralClient.new
      response = client.complete(prompt)

      LOG.info "Mistral response received (#{response&.length} chars)"
      @github.post_status(@issue, "✅ Mistral responded:\n\n#{response}")
    rescue StandardError => e
      @github.post_status(@issue, "🚫 error\n\n```\n#{e.message}\n```")
      raise
    ensure
      FileUtils.rm_f(@prompt_file)
    end
  end
end
