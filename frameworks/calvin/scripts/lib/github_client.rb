require 'octokit'

module GithubClient
  REPO = ENV.fetch('CALVIN_REPO')

  def self.client
    @client ||= Octokit::Client.new(access_token: ENV.fetch('GITHUB_TOKEN'))
  end

  def self.fetch_agent_issues
    client.issues(REPO, state: 'open', labels: 'agent', sort: 'created', direction: 'asc')
  rescue Octokit::TooManyRequests => e
    reset = e.response_headers['x-ratelimit-reset'].to_i
    sleep([reset - Time.now.to_i + 5, 0].max)
    retry
  end

  def self.fetch_model_ready_comment(issue_number)
    client.issue_comments(REPO, issue_number)
          .reverse
          .find { |c| c.body.include?('## Model-ready') }
  end

  def self.post_comment(issue_number, body)
    client.add_comment(REPO, issue_number, body)
  end

  def self.edit_comment(comment_id, body)
    client.update_comment(REPO, comment_id, body)
  end

  def self.add_label(issue_number, label)
    client.add_labels_to_an_issue(REPO, issue_number, [label])
  end

  def self.remove_label(issue_number, label)
    client.remove_label(REPO, issue_number, label)
  rescue Octokit::NotFound
  end

  def self.create_pr(title:, head:, base: 'main', body: '')
    client.create_pull_request(REPO, base, head, title, body)
  end
end
