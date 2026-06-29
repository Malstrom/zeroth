module FileWriter
  def self.head_sha(repo_path)
    `git -C #{repo_path} rev-parse HEAD`.strip
  end

  def self.run_aider(prompt_file, provider, repo_path)
    system("git -C #{repo_path} checkout -- . && git -C #{repo_path} clean -fd")
    output = `cd #{repo_path} && aider --yes --no-auto-commits --no-pretty --model #{provider} --message-file #{prompt_file} 2>&1`
    if $?.success?
      { success: true }
    elsif output.match?(/429|rate.?limit/i)
      { success: false, rate_limited: true, reason: 'rate limited' }
    else
      { success: false, reason: output.lines.last(5).join }
    end
  end

  def self.commit_and_push(repo_path, branch, message)
    system("git -C #{repo_path} checkout -b #{branch}")
    system("git -C #{repo_path} add -A")
    system("git -C #{repo_path} commit -m '#{message}'")
    system("git -C #{repo_path} push origin #{branch}")
  end

  def self.reset_hard(repo_path, sha)
    system("git -C #{repo_path} reset --hard #{sha} && git -C #{repo_path} clean -fd")
  end
end
