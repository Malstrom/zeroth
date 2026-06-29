# frameworks/calvin/scripts/lib/file_writer.rb
# Git operations and Aider execution.

module FileWriter
  def self.head_sha(repo_path)
    `git -C #{repo_path} rev-parse HEAD`.strip
  end

  def self.clean_working_tree(repo_path)
    system("git -C #{repo_path} checkout -- .")
    system("git -C #{repo_path} clean -fd")
  end

  # Runs Aider with --no-auto-commits.
  # Returns { success: true } or { success: false, reason: string, rate_limited: bool }
  def self.run_aider(prompt_file, provider, repo_path)
    clean_working_tree(repo_path)

    cmd = [
      'aider',
      '--yes',
      '--no-auto-commits',
      '--no-pretty',
      "--model #{provider}",
      "--message-file #{prompt_file}"
    ].join(' ')

    output = `cd #{repo_path} && #{cmd} 2>&1`
    exit_code = $?.exitstatus

    if exit_code == 0
      { success: true }
    elsif output.include?('429') || output.downcase.include?('rate limit')
      { success: false, rate_limited: true, reason: 'rate limited', output: output }
    else
      { success: false, rate_limited: false, reason: output.lines.last(5).join, output: output }
    end
  end

  def self.commit_and_push(repo_path, branch, message)
    system("git -C #{repo_path} checkout -b #{branch}")
    system("git -C #{repo_path} add -A")
    system("git -C #{repo_path} commit -m '#{message}'")
    system("git -C #{repo_path} push origin #{branch}")
  end

  def self.reset_hard(repo_path, sha)
    system("git -C #{repo_path} reset --hard #{sha}")
    system("git -C #{repo_path} clean -fd")
  end
end
