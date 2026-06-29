# frozen_string_literal: true

module Calvin
  class GitCommitter
    def self.commit(issue, branch) = new(issue, branch).commit

    def initialize(issue, branch)
      @issue  = issue
      @branch = branch
    end

    def commit
      checkout_branch
      `git -C #{REPO_PATH} add -A`
      `git -C #{REPO_PATH} commit -m "feat: #{@issue.title} [issue ##{@issue.number}]"`
      sha = `git -C #{REPO_PATH} rev-parse HEAD`.strip
      `git -C #{REPO_PATH} push origin #{@branch}`
      { branch: @branch, sha: sha }
    end

    private

    def checkout_branch
      `git -C #{REPO_PATH} checkout -b #{@branch} 2>/dev/null || \
       git -C #{REPO_PATH} checkout #{@branch}`
    end
  end
end
