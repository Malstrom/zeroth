# frozen_string_literal: true

module Calvin
  class Finalizer
    def self.finalize(issue, pr, result, github) = new(issue, pr, result, github).finalize

    def initialize(issue, pr, result, github)
      @issue  = issue
      @pr     = pr
      @result = result
      @github = github
    end

    def finalize
      @github.set_labels(@issue, remove: "agent", add: "agent:review")
      @github.post_status(@issue, "✅ PR ##{@pr.number} — #{@result[:provider]}")
      `git -C #{REPO_PATH} checkout main`
      FileUtils.rm_f("/tmp/calvin_prompt_#{@issue.number}.txt")
      LOG.info "##{@issue.number} done — PR ##{@pr.number}"
    end
  end
end
