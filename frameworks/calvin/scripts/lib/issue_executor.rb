# frozen_string_literal: true
# Orchestratore principale per una singola issue.
# Sequenza: costruisce contesto → prompt → chiama Mistral (design) →
#           aider applica le modifiche → git commit/push → apre PR → posta link.

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

      # Step 1: Mistral per design/guida (opzionale, aiuta aider a ragionare meglio)
      client   = MistralClient.new
      response = client.complete(prompt)
      LOG.info "Mistral response received (#{response&.length} chars)"

      # Step 2: aider applica le modifiche nel working tree
      @github.post_status(@issue, "🤖 aider is working...")
      aider_result = AiderRunner.run(@prompt_file)

      unless aider_result[:success]
        @github.post_status(@issue, "🚫 aider failed\n\n```\n#{aider_result[:reason]}\n```")
        return
      end

      LOG.info "aider succeeded with #{aider_result[:model]}"

      # Step 3: commit + push su branch dedicato
      branch      = "calvin/issue-#{@issue.number}"
      commit_info = GitCommitter.commit(@issue, branch)
      LOG.info "committed #{commit_info[:sha]} on #{commit_info[:branch]}"

      # Step 4: apre PR e posta link sull'issue
      pr = PullRequestOpener.open(@issue, branch, @github)
      @github.post_status(@issue, "✅ Done! PR aperta: #{pr[:url]}\n\n---\n_Mistral notes:_\n\n#{response}")
    rescue StandardError => e
      @github.post_status(@issue, "🚫 error\n\n```\n#{e.message}\\n#{e.backtrace.first(3).join("\\n")}\n```")
      raise
    ensure
      FileUtils.rm_f(@prompt_file)
    end
  end
end
