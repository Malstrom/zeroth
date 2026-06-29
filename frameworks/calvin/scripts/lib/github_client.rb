# frozen_string_literal: true

module Calvin
  class GitHubClient
    def initialize
      @client = Octokit::Client.new(access_token: ENV.fetch("GITHUB_TOKEN"))
    end

    def agent_issues
      @client.list_issues(REPO, labels: "agent", state: "open")
    end

    def async_ready_comment(issue)
      @client.issue_comments(REPO, issue.number)
             .find { |c| c.body.include?("## Async-ready") }
             &.body
    end

    def post_status(issue, msg)
      marker   = "<!-- calvin-status -->"
      body     = "#{marker}\n#{msg}"
      existing = @client.issue_comments(REPO, issue.number)
                        .find { |c| c.body.start_with?(marker) }
      if existing
        @client.update_comment(REPO, existing.id, body)
      else
        @client.add_comment(REPO, issue.number, body)
      end
    end

    def open_pr(issue, branch, provider)
      @client.create_pull_request(
        REPO, "main", branch,
        "[Calvin] #{issue.title}",
        "Closes ##{issue.number}\nProvider: `#{provider}`\n\n## Calvin notes\n"
      )
    end

    def set_labels(issue, remove:, add:)
      @client.remove_label(REPO, issue.number, remove) rescue nil
      @client.add_label(REPO, issue.number, add)       rescue nil
    end
  end
end
