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

    # Apre una PR da branch -> main con titolo e body standard Calvin
    def open_pr(issue, branch, model)
      @client.create_pull_request(
        REPO, "main", branch,
        "[Calvin] #{issue.title}",
        "Closes ##{issue.number}\nModel: `#{model}`\n\n## Calvin notes\n"
      )
    end

    # Rimuove un label e ne aggiunge un altro sull'issue
    def set_labels(issue, remove:, add:)
      @client.remove_label(REPO, issue.number, remove) rescue nil
      @client.add_label(REPO, issue.number, add)       rescue nil
    end
  end
end
