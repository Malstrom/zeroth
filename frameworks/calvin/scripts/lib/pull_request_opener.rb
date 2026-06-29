# frozen_string_literal: true

module Calvin
  class PullRequestOpener
    def self.open(issue, commit, result, github) = new(issue, commit, result, github).open

    def initialize(issue, commit, result, github)
      @issue  = issue
      @commit = commit
      @result = result
      @github = github
    end

    def open
      @github.open_pr(@issue, @commit[:branch], @result[:provider])
    end
  end
end
