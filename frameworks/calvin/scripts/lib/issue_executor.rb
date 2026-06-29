require_relative 'github_client'
require_relative 'file_writer'

class IssueExecutor
  REPO_PATH = ENV.fetch('CALVIN_REPO_PATH')
  PROVIDER  = 'mistral/codestral-latest'

  def initialize(issue)
    @issue  = issue
    @number = issue.number
    @status_id = nil
  end

  def run
    puts "##{@number}: #{@issue.title}"
    mr = GithubClient.fetch_model_ready_comment(@number)
    return block!('no model-ready comment') unless mr

    post_status("⏳ #{PROVIDER}")
    head_sha = FileWriter.head_sha(REPO_PATH)
    prompt   = write_prompt(mr.body)
    result   = FileWriter.run_aider(prompt, PROVIDER, REPO_PATH)

    if result[:success]
      branch = "calvin/issue-#{@number}"
      FileWriter.commit_and_push(REPO_PATH, branch, "fix: ##{@number}")
      pr = GithubClient.create_pr(
        title: "[Calvin] #{@issue.title}",
        head:  branch,
        body:  pr_body(mr.body)
      )
      GithubClient.remove_label(@number, 'agent')
      GithubClient.add_label(@number, 'agent:review')
      update_status("✅ PR ##{pr.number} · #{PROVIDER}")
    else
      FileWriter.reset_hard(REPO_PATH, head_sha)
      block!(result[:reason])
    end
  rescue StandardError => e
    block!(e.message)
  ensure
    File.delete(prompt) if prompt && File.exist?(prompt)
  end

  private

  def write_prompt(mr_body)
    context = File.read(File.join(REPO_PATH, '.context.yml')) rescue ''
    path = "/tmp/calvin_#{@number}.txt"
    File.write(path, "#{mr_body}\n\n---\n\n#{context}")
    path
  end

  def pr_body(mr_body)
    <<~MD
      Closes ##{@number}

      #{mr_body.split('## Calvin notes').first.strip}

      ## Calvin notes
    MD
  end

  def post_status(text)
    @status_id = GithubClient.post_comment(@number, text).id
  end

  def update_status(text)
    @status_id ? GithubClient.edit_comment(@status_id, text) : post_status(text)
  end

  def block!(reason)
    GithubClient.remove_label(@number, 'agent') rescue nil
    GithubClient.add_label(@number, 'agent:blocked') rescue nil
    update_status("🚫 #{reason}")
  end
end
