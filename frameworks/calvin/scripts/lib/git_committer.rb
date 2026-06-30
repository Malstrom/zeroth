# frozen_string_literal: true
# Crea il branch per l'issue, committa le modifiche di aider e fa push.

module Calvin
  class GitCommitter
    def self.commit(issue, branch) = new(issue, branch).commit

    def initialize(issue, branch)
      @issue  = issue
      @branch = branch
    end

    def commit
      checkout_branch
      `git add -A`
      `git commit -m "feat: #{@issue.title} [issue ##{@issue.number}]"`
      sha = `git rev-parse HEAD`.strip
      `git push origin #{@branch}`
      { branch: @branch, sha: sha }
    end

    private

    # Crea il branch se non esiste, altrimenti fa checkout
    def checkout_branch
      `git checkout -b #{@branch} 2>/dev/null || git checkout #{@branch}`
    end
  end
end
