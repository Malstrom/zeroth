# frozen_string_literal: true
# Entry point per GitHub Actions.
# Viene chiamato dal workflow calvin-engine.yml con ISSUE_NUMBER nell'env.
# Legge l'issue, costruisce il contesto, chiama Mistral, aider applica le modifiche, apre la PR.

require "octokit"
require "open3"
require "yaml"
require "fileutils"
require "logger"
require_relative "lib/github_client"
require_relative "lib/context_builder"
require_relative "lib/prompt_builder"
require_relative "lib/mistral_client"
require_relative "lib/aider_runner"
require_relative "lib/git_committer"
require_relative "lib/pull_request_opener"
require_relative "lib/finalizer"
require_relative "lib/issue_executor"

module Calvin
  # Repo target nel formato "owner/repo" — usato da Octokit
  REPO = ENV.fetch("GITHUB_REPOSITORY")

  # Cartella .calvin nel repo target (clonato da actions/checkout)
  CALVIN_DIR = File.join(Dir.pwd, ".calvin")

  LOG = Logger.new($stdout).tap do |l|
    l.formatter = proc { |sev, _, _, msg| "[calvin] #{sev}: #{msg}\n" }
  end
end

# Legge il numero di issue dall'env passato dal workflow
issue_number = ENV.fetch("ISSUE_NUMBER").to_i

github = Calvin::GitHubClient.new
issue  = github.fetch_issue(issue_number)

Calvin::LOG.info "processing ##{issue_number}: #{issue.title}"
Calvin::IssueExecutor.new(issue, github).run
