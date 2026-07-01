# frozen_string_literal: true
# Wrapper Octokit. Centralizza tutte le chiamate GitHub API.

module Calvin
  class GitHubClient
    def initialize
      @client = Octokit::Client.new(access_token: ENV.fetch("GITHUB_TOKEN"))
    end

    # Ritorna l'issue dal repo target per numero
    def fetch_issue(number)
      @client.issue(REPO, number)
    end

    # Aggiorna o crea il commento di stato di Calvin sull'issue
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
  end
end
