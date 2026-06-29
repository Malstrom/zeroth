# frozen_string_literal: true
# .calvin/calvin.rb — entry point. Start: ruby .calvin/calvin.rb

require "octokit"
require "open3"
require "yaml"
require "fileutils"
require "logger"
require_relative "lib/github_client"
require_relative "lib/context_builder"
require_relative "lib/prompt_builder"
require_relative "lib/aider_runner"
require_relative "lib/git_committer"
require_relative "lib/pull_request_opener"
require_relative "lib/finalizer"
require_relative "lib/issue_executor"

module Calvin
  REPO          = ENV.fetch("CALVIN_REPO")
  REPO_PATH     = ENV.fetch("CALVIN_REPO_PATH")
  CALVIN_DIR    = File.join(REPO_PATH, ".calvin")
  POLL_INTERVAL = ENV.fetch("CALVIN_POLL_INTERVAL", "300").to_i
  LOG           = Logger.new($stdout).tap do |l|
    l.formatter = proc { |sev, _, _, msg| "[calvin] #{sev}: #{msg}\n" }
  end
  PROVIDERS = %w[
    cerebras/gpt-oss-120b
    mistral/codestral-latest
    groq/llama-3.3-70b-versatile
    gemini/gemini-2.5-flash
    openrouter/deepseek/deepseek-chat-v4-flash:free
    ollama/qwen2.5:32b
  ].freeze
end

github = Calvin::GitHubClient.new
Calvin::LOG.info "started — repo: #{Calvin::REPO} — interval: #{Calvin::POLL_INTERVAL}s"

loop do
  begin
    github.agent_issues.each do |issue|
      Calvin::IssueExecutor.new(issue, github).run
    end
  rescue StandardError => e
    Calvin::LOG.error "loop error: #{e.message}"
  end
  sleep Calvin::POLL_INTERVAL
end
