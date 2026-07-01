# frozen_string_literal: true
# Orchestratore Calvin — entry point per GitHub Actions.
# Ogni step riceve il CalvinRun, lo arricchisce e lo passa al successivo.
# Le classi in lib/ sono pure trasformazioni: nessuna sa del flusso globale.

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
require_relative "lib/aider_runner"
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

  # 2. Prompt separati: Mistral (solo analisi) e aider (implementazione completa)
  run.mistral_prompt = Calvin::PromptBuilder.build_for_mistral(run.issue, run.context)
  run.aider_prompt   = Calvin::PromptBuilder.build_for_aider(run.issue, run.context)

  # 3. Mistral — analisi, note architetturali, piano di implementazione
  run.notes = Calvin::MistralClient.new.complete(run.mistral_prompt)
  Calvin::LOG.info "Mistral notes received (#{run.notes&.length} chars)"

  # 4. File di contesto per aider — routes, application_controller, controller/test esistenti
  run.context_files = [
    "backend/api/config/routes.rb",
    "backend/api/app/controllers/application_controller.rb",
    *Dir.glob("backend/api/app/controllers/api/v1/*.rb").first(3),
    *Dir.glob("backend/api/test/controllers/api/v1/*_test.rb").first(2)
  ].select { |f| File.exist?(f) }

  Calvin::LOG.info "aider context: #{run.context_files.join(', ')}"
  github.post_status(run.issue, "🤖 aider is working...")

  # 5. aider — implementa tutto nel working tree (no auto-commit)
  run.aider_result = Calvin::AiderRunner.run(run.aider_prompt, files: run.context_files)

  unless run.aider_result[:success]
    github.post_status(run.issue, "🚫 aider failed\n\n```\n#{run.aider_result[:reason]}\n```")
    exit 1
  end

  # 6. Commit + push su branch dedicato
  run.commit = Calvin::GitCommitter.commit(run.issue, "calvin/issue-#{run.issue.number}")
  Calvin::LOG.info "committed #{run.commit[:sha]} on #{run.commit[:branch]}"

  # 7. Apre PR su GitHub
  run.pr = Calvin::PullRequestOpener.open(run.issue, run.commit, run.aider_result, github)

  # 8. Finalizza: aggiorna label, posta stato, torna su main
  Calvin::Finalizer.finalize(run.issue, run.pr, run.aider_result, github)

  # 9. Posta note Mistral sull'issue
  github.post_status(run.issue, "✅ PR aperta: #{run.pr.html_url}\n\n---\n_Mistral notes:_\n\n#{run.notes}")

rescue StandardError => e
  Calvin::LOG.error "#{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
  github.post_status(run.issue, "🚫 error\n\n```\n#{e.message}\n#{e.backtrace.first(3).join("\n")}\n```")
  exit 1
end
