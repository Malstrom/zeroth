# frozen_string_literal: true

module Calvin
  class IssueExecutor
    def initialize(issue, github)
      @issue   = issue
      @github  = github
      @branch  = "calvin/issue-#{issue.number}"
      @prompt_file = "/tmp/calvin_prompt_#{issue.number}.txt"
    end

    def run
      LOG.info "processing ##{@issue.number}: #{@issue.title}"

      async_comment = @github.async_ready_comment(@issue)
      unless async_comment
        LOG.warn "##{@issue.number}: no Async-ready comment — skipping"
        return
      end

      @github.post_status(@issue, "⏳ processing...")

      context = ContextBuilder.build(@issue).merge(async_ready_comment: async_comment)
      prompt  = PromptBuilder.build(@issue, context)
      File.write(@prompt_file, prompt)

      result = AiderRunner.run(@prompt_file)

      if result[:success]
        commit = GitCommitter.commit(@issue, @branch)
        pr     = PullRequestOpener.open(@issue, commit, result, @github)
        Finalizer.finalize(@issue, pr, result, @github)
      else
        @github.set_labels(@issue, remove: "agent", add: "agent:blocked")
        @github.post_status(@issue, "🚫 blocked\n\n```\n#{result[:reason].lines.last(5).join}\n```")
        `git -C #{REPO_PATH} checkout main`
      end
    end
  end
end
