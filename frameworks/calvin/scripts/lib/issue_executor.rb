# frozen_string_literal: true
# Orchestratore principale per una singola issue.
# Sequenza: costruisce contesto → prompt → aider → commit → PR → finalizza.

module Calvin
  class IssueExecutor
    def initialize(issue, github)
      @issue       = issue
      @github      = github
      @branch      = "calvin/issue-#{issue.number}"
      @prompt_file = "/tmp/calvin_prompt_#{issue.number}.txt"
    end

    def run
      @github.post_status(@issue, "⏳ processing...")

      # Costruisce contesto da .calvin/ e assembla il prompt
      context = ContextBuilder.build(@issue)
      prompt  = PromptBuilder.build(@issue, context)
      File.write(@prompt_file, prompt)

      result = AiderRunner.run(@prompt_file)

      if result[:success]
        # Committa le modifiche e apre la PR
        commit = GitCommitter.commit(@issue, @branch)
        pr     = @github.open_pr(@issue, commit[:branch], result[:model])
        Finalizer.finalize(@issue, pr, result, @github)
      else
        # Marca l'issue come bloccata e posta l'errore
        @github.set_labels(@issue, remove: "agent", add: "agent:blocked")
        @github.post_status(@issue, "🚫 blocked\n\n```\n#{result[:reason].lines.last(5).join}\n```")
        `git checkout main`
      end
    ensure
      FileUtils.rm_f(@prompt_file)
    end
  end
end
