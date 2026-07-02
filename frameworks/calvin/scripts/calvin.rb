# frozen_string_literal: true
# Orchestratore Calvin — entry point per GitHub Actions.
#
# Due modalità selezionate dalla label sull'issue:
#
#   label: agent        → issue → contesto → Codestral/Mistral → commento con codice
#   label: agent-aider  → issue → contesto → Codestral → Aider → CI loop → PR
#                          + commento minimale sull'issue con 🟢/🔴 e link PR

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

module Calvin
  REPO       = ENV.fetch("GITHUB_REPOSITORY")
  CALVIN_DIR = File.join(Dir.pwd, ".calvin")
  LOG        = Logger.new($stdout).tap do |l|
    l.formatter = proc { |sev, _, _, msg| "[calvin] #{sev}: #{msg}\n" }
  end

  AIDER_MODE_LABEL   = "agent-aider"
  COMMENT_MODE_LABEL = "agent"
  MAX_CI_RETRIES     = 2
end

github  = Calvin::GitHubClient.new
issue   = github.fetch_issue(ENV.fetch("ISSUE_NUMBER").to_i)
labels  = issue.labels.map(&:name)
aider_mode = labels.include?(Calvin::AIDER_MODE_LABEL)

run = CalvinRun.new(issue: issue)

Calvin::LOG.info "processing ##{run.issue.number}: #{run.issue.title}"
Calvin::LOG.info "mode: #{aider_mode ? 'aider' : 'comment'}"

begin
  # ── 1. Contesto + Prompt (comune a entrambe le modalità) ──────────────────
  run.context        = Calvin::ContextBuilder.build(run.issue)
  run.mistral_prompt = Calvin::PromptBuilder.build(run.issue, run.context)
  Calvin::LOG.info "Prompt built (#{run.mistral_prompt.length} chars)"

  llm = Calvin::MistralClient.new

  if aider_mode
    # ── MODALITÀ AIDER ───────────────────────────────────────────────────────

    # 2. Codestral genera il codice
    run.generated_code = llm.generate_code(run.mistral_prompt)
    Calvin::LOG.info "Code generated (#{run.generated_code.length} chars)"

    # 3. Crea branch e configura git
    issue_slug  = run.issue.title.downcase.gsub(/[^a-z0-9]+/, "-").slice(0, 40).chomp("-")
    run.branch  = "feat/#{issue_slug}-#{run.issue.number}"
    system("git checkout -b #{run.branch}") or raise "git checkout failed"
    Calvin::LOG.info "Branch: #{run.branch}"

    # 4. Aider applica il codice + CI loop
    aider = Calvin::AiderRunner.new
    ci    = Calvin::CiRunner.new

    Calvin::MAX_CI_RETRIES.times do |attempt|
      Calvin::LOG.info "Aider apply — attempt #{attempt + 1}"
      aider.apply(run.generated_code)

      result = ci.run
      run.ci_passed = result.passed

      if result.passed
        Calvin::LOG.info "CI passed on attempt #{attempt + 1}"
        break
      else
        Calvin::LOG.warn "CI failed on attempt #{attempt + 1}, asking Codestral for fix..."
        run.generated_code = llm.fix_ci(run.mistral_prompt, result.output)
      end
    end

    # 5. Push branch
    repo_url = "https://x-access-token:#{ENV.fetch('GITHUB_TOKEN')}@github.com/#{Calvin::REPO}.git"
    system("git remote set-url origin #{repo_url}")
    system("git push origin #{run.branch} --force-with-lease") or raise "git push failed"

    # 6. Apri PR (solo se CI verde, ma apri comunque con warning se rosso)
    run.pr_url = Calvin::PrBuilder.new.open(branch: run.branch, issue: run.issue)

    # 7. Commento minimale sull'issue
    status_icon = run.ci_passed ? "🟢" : "🔴"
    ci_label    = run.ci_passed ? "CI passed" : "CI failed after #{Calvin::MAX_CI_RETRIES} attempts"
    comment = <<~MD
      <!-- calvin-status -->
      **Calvin** · `#{run.branch}`
      #{status_icon} #{ci_label} · [PR aperta](#{run.pr_url})
    MD
    github.post_status(run.issue, comment)

  else
    # ── MODALITÀ COMMENTO (flusso originale) ────────────────────────────────

    run.notes = llm.complete(run.mistral_prompt)
    Calvin::LOG.info "LLM response received (#{run.notes&.length} chars)"

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
  end

rescue StandardError => e
  Calvin::LOG.error "#{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
  github.post_status(run.issue, "🚫 error\n\n```\n#{e.message}\n#{e.backtrace.first(3).join("\n")}\n```")
  exit 1
end
