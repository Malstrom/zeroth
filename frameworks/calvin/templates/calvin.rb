# frozen_string_literal: true

# .calvin/calvin.rb
# Calvin execution engine — Option B (Aider wrapper)
# Runs continuously on WSL. Start with: ruby .calvin/calvin.rb
#
# Required env vars:
#   GITHUB_TOKEN       — personal access token
#   CALVIN_REPO        — e.g. Malstrom/synca
#   CALVIN_REPO_PATH   — local path to repo clone in WSL
#
# Optional env vars:
#   CALVIN_POLL_INTERVAL  — seconds between polls (default: 300)
#   CEREBRAS_API_KEY, CODESTRAL_API_KEY, GROQ_API_KEY,
#   GEMINI_API_KEY, OPENROUTER_API_KEY

require "octokit"
require "open3"
require "yaml"
require "fileutils"
require "logger"

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

REPO        = ENV.fetch("CALVIN_REPO")
REPO_PATH   = ENV.fetch("CALVIN_REPO_PATH")
POLL_INTERVAL = ENV.fetch("CALVIN_POLL_INTERVAL", "300").to_i
CALVIN_DIR  = File.join(REPO_PATH, ".calvin")

PROVIDERS = [
  "cerebras/gpt-oss-120b",
  "mistral/codestral-latest",
  "groq/llama-3.3-70b-versatile",
  "gemini/gemini-2.5-flash",
  "openrouter/deepseek/deepseek-chat-v4-flash:free",
  "ollama/qwen2.5:32b"
].freeze

LOG = Logger.new($stdout)
LOG.formatter = proc { |sev, _, _, msg| "[calvin] #{sev}: #{msg}\n" }

GITHUB = Octokit::Client.new(access_token: ENV.fetch("GITHUB_TOKEN"))

# ---------------------------------------------------------------------------
# Context loader
# ---------------------------------------------------------------------------

def load_context(issue)
  context = {}

  %w[conventions stack decisions].each do |name|
    path = File.join(CALVIN_DIR, "#{name}.yml")
    context[name] = File.read(path) if File.exist?(path)
  end

  schema_path = File.join(CALVIN_DIR, "schema.yml")
  if File.exist?(schema_path)
    schema = YAML.safe_load(File.read(schema_path)) || {}
    relevant = extract_model_names(issue).filter_map { |m| [m, schema[m]] if schema[m] }
    context["schema"] = relevant.to_h.transform_keys(&:to_s) unless relevant.empty?
  end

  context
end

def extract_model_names(issue)
  text = "#{issue.title} #{issue.body}"
  text.scan(/[A-Z][a-zA-Z]+/).uniq
end

# ---------------------------------------------------------------------------
# Prompt builder
# ---------------------------------------------------------------------------

def build_prompt(issue, qwen_comment, context)
  parts = []

  parts << "## Context\n"
  parts << "### conventions\n```yaml\n#{context['conventions']}\n```\n" if context["conventions"]
  parts << "### stack\n```yaml\n#{context['stack']}\n```\n"               if context["stack"]
  parts << "### decisions\n```yaml\n#{context['decisions']}\n```\n"       if context["decisions"]
  if context["schema"]
    parts << "### schema (relevant models only)\n```yaml\n#{context['schema'].to_yaml}\n```\n"
  end

  parts << "\n## Issue ##{issue.number}: #{issue.title}\n"
  parts << "\n#{qwen_comment}\n"
  parts << "\n## Calvin notes\nAfter completing the task, add a `## Calvin notes` section in the PR body with:\n"
  parts << "- patterns used that should be added to conventions.yml\n"
  parts << "- decisions made that should be added to decisions.yml\n"

  parts.join
end

# ---------------------------------------------------------------------------
# Aider runner
# ---------------------------------------------------------------------------

def run_aider(prompt_file, provider)
  cmd = [
    "aider",
    "--yes",
    "--no-auto-commits",
    "--no-pretty",
    "--model", provider,
    "--message-file", prompt_file
  ]

  stdout, stderr, status = Open3.capture3(*cmd, chdir: REPO_PATH)
  output = stdout + stderr

  {
    success: status.success? && !output.match?(/error|traceback/i),
    rate_limited: output.match?(/429|rate.?limit/i),
    output: output
  }
end

def run_with_fallback(prompt_file)
  head_sha = `git -C #{REPO_PATH} rev-parse HEAD`.strip

  PROVIDERS.each do |provider|
    LOG.info "trying #{provider}"
    `git -C #{REPO_PATH} checkout -- .`
    `git -C #{REPO_PATH} clean -fd`

    result = run_aider(prompt_file, provider)

    if result[:success]
      LOG.info "success with #{provider}"
      return { success: true, provider: provider }
    elsif result[:rate_limited]
      LOG.info "#{provider} rate limited — trying next"
      next
    else
      LOG.warn "#{provider} failed: #{result[:output].lines.last(3).join}"
      `git -C #{REPO_PATH} reset --hard #{head_sha}`
      return { success: false, reason: result[:output] }
    end
  end

  `git -C #{REPO_PATH} reset --hard #{head_sha}`
  { success: false, reason: "all providers exhausted" }
end

# ---------------------------------------------------------------------------
# GitHub helpers
# ---------------------------------------------------------------------------

def fetch_agent_issues
  GITHUB.list_issues(REPO, labels: "agent", state: "open")
end

def qwen_ready_comment(issue)
  comments = GITHUB.issue_comments(REPO, issue.number)
  comments.find { |c| c.body.include?("## Qwen-ready") }&.body
end

def post_status(issue, msg)
  existing = GITHUB.issue_comments(REPO, issue.number)
                   .find { |c| c.body.start_with?("<!-- calvin-status -->") }
  if existing
    GITHUB.update_comment(REPO, existing.id, "<!-- calvin-status -->\n#{msg}")
  else
    GITHUB.add_comment(REPO, issue.number, "<!-- calvin-status -->\n#{msg}")
  end
end

def open_pr(issue, branch, provider, tokens: nil)
  token_info = tokens ? " · #{tokens}" : ""
  GITHUB.create_pull_request(
    REPO,
    "main",
    branch,
    "[Calvin] #{issue.title}",
    "Closes ##{issue.number}\n\nProvider: `#{provider}`#{token_info}\n\n## Calvin notes\n"
  )
end

# ---------------------------------------------------------------------------
# Issue executor
# ---------------------------------------------------------------------------

def execute_issue(issue)
  LOG.info "processing issue ##{issue.number}: #{issue.title}"

  qwen_comment = qwen_ready_comment(issue)
  unless qwen_comment
    LOG.warn "##{issue.number}: no Qwen-ready comment — skipping"
    return
  end

  post_status(issue, "⏳ processing issue ##{issue.number}...")

  context = load_context(issue)
  prompt  = build_prompt(issue, qwen_comment, context)

  prompt_file = "/tmp/calvin_prompt_#{issue.number}.txt"
  File.write(prompt_file, prompt)

  branch = "calvin/issue-#{issue.number}"
  `git -C #{REPO_PATH} checkout -b #{branch} 2>/dev/null || git -C #{REPO_PATH} checkout #{branch}`

  result = run_with_fallback(prompt_file)

  unless result[:success]
    GITHUB.remove_label(REPO, issue.number, "agent") rescue nil
    GITHUB.add_label(REPO, issue.number, "agent:blocked") rescue nil
    post_status(issue, "🚫 blocked\n\n```\n#{result[:reason].lines.last(5).join}\n```")
    `git -C #{REPO_PATH} checkout main`
    return
  end

  `git -C #{REPO_PATH} add -A`
  `git -C #{REPO_PATH} commit -m "feat: #{issue.title} [issue ##{issue.number}]"`
  `git -C #{REPO_PATH} push origin #{branch}`

  pr = open_pr(issue, branch, result[:provider])

  GITHUB.remove_label(REPO, issue.number, "agent") rescue nil
  GITHUB.add_label(REPO, issue.number, "agent:review") rescue nil
  post_status(issue, "✅ done — PR ##{pr.number} · #{result[:provider]}")

  `git -C #{REPO_PATH} checkout main`
  FileUtils.rm_f(prompt_file)

  LOG.info "##{issue.number} done — PR ##{pr.number}"
end

# ---------------------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------------------

LOG.info "calvin started — repo: #{REPO} — poll interval: #{POLL_INTERVAL}s"

loop do
  begin
    issues = fetch_agent_issues
    LOG.info "#{issues.size} issue(s) in queue"
    issues.each { |issue| execute_issue(issue) }
  rescue StandardError => e
    LOG.error "loop error: #{e.message}"
  end

  sleep POLL_INTERVAL
end
