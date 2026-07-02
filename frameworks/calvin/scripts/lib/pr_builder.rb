# frozen_string_literal: true
# Apre una Pull Request sul repo target via Octokit.
# Branch sorgente già pushato da Aider.
#
# Uso:
#   url = Calvin::PrBuilder.new.open(
#     branch: "feat/us-01-guest-account",
#     issue:  issue_object
#   )
#   # => "https://github.com/owner/repo/pull/42"

module Calvin
  class PrBuilder
    BASE_BRANCH = "main"

    def initialize
      @client = Octokit::Client.new(access_token: ENV.fetch("GITHUB_TOKEN"))
    end

    def open(branch:, issue:)
      title = "[Calvin] #{issue.title}"
      body  = <<~MD
        Closes ##{issue.number}

        > Auto-implemented by Calvin (Codestral + Aider).
        > Review carefully before merging.
      MD

      pr = @client.create_pull_request(
        REPO,
        BASE_BRANCH,
        branch,
        title,
        body
      )

      Calvin::LOG.info "PR opened: #{pr.html_url}"
      pr.html_url
    rescue Octokit::UnprocessableEntity => e
      # PR già esistente per questo branch
      Calvin::LOG.warn "PR already exists or branch issue: #{e.message}"
      existing = @client.pull_requests(REPO, head: "#{REPO.split('/').first}:#{branch}", state: "open")
      existing.first&.html_url
    end
  end
end
