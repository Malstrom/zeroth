# frameworks/calvin/scripts/lib/issue_executor.rb
# Orchestrates execution of a single issue:
# model-ready comment → Aider → validate → PR

require_relative 'github_client'
require_relative 'file_writer'

class IssueExecutor
  REPO_PATH = ENV['CALVIN_REPO_PATH'] || raise('CALVIN_REPO_PATH not set')

  # Single provider for Phase 1. Extend to array + fallback loop in Phase 2.
  PROVIDER = 'mistral/codestral-latest'

  def initialize(issue)
    @issue = issue
    @issue_number = issue.number
    @status_comment_id = nil
  end

  def run
    puts "Processing issue ##{@issue_number}: #{@issue.title}"

    model_ready = GithubClient.fetch_model_ready_comment(@issue_number)
    unless model_ready
      block!("No model-ready comment found on issue ##{@issue_number}.")
      return
    end

    post_status("⏳ starting — #{PROVIDER}")

    head_sha = FileWriter.head_sha(REPO_PATH)
    prompt_file = write_prompt(model_ready.body)

    result = FileWriter.run_aider(prompt_file, PROVIDER, REPO_PATH)

    if result[:success]
      branch = "calvin/issue-#{@issue_number}"
      FileWriter.commit_and_push(REPO_PATH, branch, "fix: resolve issue ##{@issue_number}")
      pr = GithubClient.create_pr(
        title: "[Calvin] #{@issue.title}",
        head: branch,
        body: pr_body(model_ready.body)
      )
      GithubClient.remove_label(@issue_number, 'agent')
      GithubClient.add_label(@issue_number, 'agent:review')
      update_status("✅ done — PR ##{pr.number} · #{PROVIDER}")
      puts "PR ##{pr.number} opened for issue ##{@issue_number}."
    else
      FileWriter.reset_hard(REPO_PATH, head_sha)
      block!(result[:reason])
    end

  rescue StandardError => e
    block!("Unexpected error: #{e.message}")
  ensure
    File.delete(prompt_file) if prompt_file && File.exist?(prompt_file)
  end

  private

  def write_prompt(model_ready_body)
    path = "/tmp/calvin_prompt_#{@issue_number}.txt"
    context = File.read(File.join(REPO_PATH, '.context.yml')) rescue ''
    File.write(path, "#{model_ready_body}\n\n---\n\n#{context}")
    path
  end

  def pr_body(model_ready_body)
    <<~MD
      Closes ##{@issue_number}

      #{model_ready_body.split('## Calvin notes').first.strip}

      ## Calvin notes

      <!-- Fill after review -->
    MD
  end

  def post_status(text)
    comment = GithubClient.post_comment(@issue_number, text)
    @status_comment_id = comment.id
  end

  def update_status(text)
    return post_status(text) unless @status_comment_id
    GithubClient.edit_comment(@status_comment_id, text)
  end

  def block!(reason)
    GithubClient.remove_label(@issue_number, 'agent') rescue nil
    GithubClient.add_label(@issue_number, 'agent:blocked') rescue nil
    update_status("🚫 blocked — #{reason}")
    puts "Issue ##{@issue_number} blocked: #{reason}"
  end
end
