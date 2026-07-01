# frozen_string_literal: true
# Orchestratore Calvin — entry point per GitHub Actions.
# Pipeline: issue → contesto → note Mistral → codice Mistral → scrivi file → commit → PR

require "octokit"
require "open3"
require "yaml"
require "fileutils"
require "logger"
require_relative "lib/calvin_run"
require_relative "lib/github_client"
require_relative "lib/context_builder"
require_relative "lib/prompt_builder"
require_relative "lib/mistral_client"
require_relative "lib/code_writer"
require_relative "lib/git_committer"
require_relative "lib/pull_request_opener"
require_relative "lib/finalizer"

module Calvin
  REPO       = ENV.fetch("GITHUB_REPOSITORY")
  CALVIN_DIR = File.join(Dir.pwd, ".calvin")
  LOG = Logger.new($stdout).tap do |l|
    l.formatter = proc { |sev, _, _, msg| "[calvin] #{sev}: #{msg}\n" }
  end
end

github = Calvin::GitHubClient.new
run    = CalvinRun.new(issue: github.fetch_issue(ENV.fetch("ISSUE_NUMBER").to_i))

Calvin::LOG.info "processing ##{run.issue.number}: #{run.issue.title}"
github.post_status(run.issue, "⏳ processing...")

begin
  # 1. Contesto — legge .calvin/ e schema rilevante
  run.context = Calvin::ContextBuilder.build(run.issue)

  # 2. Prompt
  run.mistral_prompt = Calvin::PromptBuilder.build_for_mistral(run.issue, run.context)
  run.aider_prompt   = Calvin::PromptBuilder.build_for_aider(run.issue, run.context)

  mistral = Calvin::MistralClient.new

  # 3. Note architetturali (mistral-small)
  run.notes = mistral.complete(run.mistral_prompt)
  Calvin::LOG.info "Mistral notes received (#{run.notes&.length} chars)"

  github.post_status(run.issue, "⚙️ generating code...")

  # 4. Generazione codice (codestral) — ritorna [{path:, content:}]
  generated = mistral.generate_files(run.aider_prompt)
  Calvin::LOG.info "Mistral generated #{generated.size} file(s): #{generated.map { |f| f[:path] }.join(', ')}"

  run.aider_result = { success: true, model: "codestral-latest" }

  # 5. Scrivi i file nel working tree
  Calvin::CodeWriter.write(generated)

  # 6. Commit + push su branch dedicato
  run.commit = Calvin::GitCommitter.commit(run.issue, "calvin/issue-#{run.issue.number}")
  Calvin::LOG.info "committed #{run.commit[:sha]} on #{run.commit[:branch]}"

  # 7. Apre PR
  run.pr = Calvin::PullRequestOpener.open(run.issue, run.commit, run.aider_result, github)

  # 8. Finalizza
  Calvin::Finalizer.finalize(run.issue, run.pr, run.aider_result, github)

  # 9. Posta note Mistral sull'issue
  github.post_status(run.issue, "✅ PR aperta: #{run.pr.html_url}\n\n---\n_Mistral notes:_\n\n#{run.notes}")

rescue StandardError => e
  Calvin::LOG.error "#{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
  github.post_status(run.issue, "🚫 error\n\n```\n#{e.message}\n#{e.backtrace.first(3).join("\n")}\n```")
  exit 1
end
