#!/usr/bin/env ruby
# frameworks/calvin/scripts/poll.rb
# Async execution loop — Phase 2 (Mistral).
# Copy to .calvin/poll.rb in the target repo.
# Configure env vars before running.
#
# Usage:
#   GITHUB_TOKEN=xxx CALVIN_REPO=owner/repo CALVIN_REPO_PATH=/path/to/repo \
#   CODESTRAL_API_KEY=xxx ruby .calvin/poll.rb
#
# Required env vars:
#   GITHUB_TOKEN        GitHub personal access token
#   CALVIN_REPO         target repo in format owner/repo
#   CALVIN_REPO_PATH    absolute path to local clone of target repo
#
# Optional env vars:
#   CALVIN_POLL_INTERVAL   polling interval in seconds (default: 300)
#   CODESTRAL_API_KEY      Mistral Codestral API key
#   OLLAMA_HOST            Ollama endpoint (default: http://localhost:11434)

require_relative 'lib/github_client'
require_relative 'lib/issue_executor'

POLL_INTERVAL = (ENV['CALVIN_POLL_INTERVAL'] || 300).to_i

puts "Calvin poll.rb starting — repo: #{ENV['CALVIN_REPO']}, interval: #{POLL_INTERVAL}s"

loop do
  begin
    issues = GithubClient.fetch_agent_issues
    if issues.empty?
      puts "[#{Time.now}] No agent issues found. Sleeping #{POLL_INTERVAL}s."
    else
      puts "[#{Time.now}] Found #{issues.count} issue(s) to process."
      issues.each do |issue|
        IssueExecutor.new(issue).run
      end
    end
  rescue StandardError => e
    puts "[#{Time.now}] ERROR in main loop: #{e.message}"
    puts e.backtrace.first(5).join("\n")
  end

  sleep POLL_INTERVAL
end
