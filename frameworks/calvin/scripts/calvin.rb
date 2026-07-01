# frozen_string_literal: true
# Orchestratore Calvin — entry point per GitHub Actions.
# Pipeline: issue → contesto → Mistral → commento sull'issue con prompt + risposta

require "octokit"
require "yaml"
require "fileutils"
require "logger"
require_relative "lib/calvin_run"
require_relative "lib/github_client"
require_relative "lib/context_builder"
require_relative "lib/prompt_builder"
require_relative "lib/mistral_client"

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
  # 1. Contesto
  run.context = Calvin::ContextBuilder.build(run.issue)

  # 2. Prompt
  run.mistral_prompt = Calvin::PromptBuilder.build(run.issue, run.context)
  Calvin::LOG.info "Prompt built (#{run.mistral_prompt.length} chars)"

  # 3. Mistral
  run.notes = Calvin::MistralClient.new.complete(run.mistral_prompt)
  Calvin::LOG.info "Mistral response received (#{run.notes&.length} chars)"

  # 4. Posta prompt + risposta come commento sull'issue
  comment = <<~MD
    <!-- calvin-status -->
    ## 📤 Prompt inviato a Mistral

    <details>
    <summary>Espandi prompt</summary>

    ```
    #{run.mistral_prompt}
    ```

    </details>

    ---

    ## 🤖 Risposta Mistral

    #{run.notes}
  MD

  github.post_status(run.issue, comment)
  Calvin::LOG.info "##{run.issue.number} done"

rescue StandardError => e
  Calvin::LOG.error "#{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
  github.post_status(run.issue, "🚫 error\n\n```\n#{e.message}\n#{e.backtrace.first(3).join("\n")}\n```")
  exit 1
end
