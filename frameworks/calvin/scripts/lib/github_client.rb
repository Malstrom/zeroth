# frameworks/calvin/scripts/lib/github_client.rb
# All GitHub API interactions via Octokit.

require 'octokit'

module GithubClient
  REPO = ENV['CALVIN_REPO'] || raise('CALVIN_REPO not set')

  def self.client
    @client ||= Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
  end

  # Returns all open issues with label `agent`, sorted by number ascending.
  def self.fetch_agent_issues
    client.issues(REPO, state: 'open', labels: 'agent', sort: 'created', direction: 'asc')
  rescue Octokit::TooManyRequests => e
    puts "GitHub rate limit hit. Reset at: #{e.response_headers['x-ratelimit-reset']}"
    sleep_until_reset(e.response_headers['x-ratelimit-reset'].to_i)
    retry
  end

  # Returns the model-ready comment on an issue (last comment with ## Model-ready header).
  def self.fetch_model_ready_comment(issue_number)
    comments = client.issue_comments(REPO, issue_number)
    comments.reverse.find { |c| c.body.include?('## Model-ready') }
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
    # label not present — safe to ignore
  end

  def self.create_pr(title:, head:, base: 'main', body: '')
    client.create_pull_request(REPO, base, head, title, body)
  end

  private

  def self.sleep_until_reset(reset_timestamp)
    wait = [reset_timestamp - Time.now.to_i + 5, 0].max
    puts "Sleeping #{wait}s until GitHub rate limit resets."
    sleep wait
  end
end
