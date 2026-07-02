# frozen_string_literal: true
# Orchestratore Calvin — entry point per GitHub Actions.
#
# label: agent       → CommentFlow  (Mistral risponde con markdown sull'issue)
# label: agent-aider → AiderFlow    (Aider genera, scrive i file, apre PR)

require "octokit"
require "yaml"
require "fileutils"
require "logger"
require "timeout"
require_relative "lib/calvin_run"
require_relative "lib/github_client"
require_relative "lib/context_builder"
require_relative "lib/prompt_builder"
require_relative "lib/mistral_client"
require_relative "lib/aider_runner"
require_relative "lib/ci_runner"
require_relative "lib/pr_builder"
require_relative "lib/aider_flow"
require_relative "lib/comment_flow"

module Calvin
  REPO = ENV.fetch("GITHUB_REPOSITORY")
  LOG  = Logger.new($stdout).tap do |l|
    l.formatter = proc { |sev, _, _, msg| "[calvin] #{sev}: #{msg}\n" }
  end
end

github     = Calvin::GitHubClient.new
issue      = github.fetch_issue(ENV.fetch("ISSUE_NUMBER").to_i)
aider_mode = issue.labels.map(&:name).include?("agent-aider")

Calvin::LOG.info "processing ##{issue.number}: #{issue.title}"
Calvin::LOG.info "mode: #{aider_mode ? 'aider' : 'comment'}"

begin
  context = Calvin::ContextBuilder.build(issue)
  prompt  = Calvin::PromptBuilder.build(issue, context)

  if aider_mode
    Calvin::AiderFlow.new(github, issue, prompt).run
  else
    Calvin::CommentFlow.new(github, issue, prompt).run
  end
rescue StandardError => e
  Calvin::LOG.error "#{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
  github.post_status(issue, "\u{1F6AB} error\n\n```\n#{e.message}\n#{e.backtrace.first(3).join("\n")}\n```")
  exit 1
end
