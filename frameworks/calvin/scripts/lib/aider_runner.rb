# frozen_string_literal: true

module Calvin
  class AiderRunner
    def self.run(prompt_file) = new(prompt_file).run_with_fallback

    def initialize(prompt_file)
      @prompt_file = prompt_file
    end

    def run_with_fallback
      head_sha = git("rev-parse HEAD").strip

      PROVIDERS.each do |provider|
        LOG.info "trying #{provider}"
        git("checkout -- .")
        git("clean -fd")

        result = call_aider(provider)

        if result[:success]
          LOG.info "success with #{provider}"
          return { success: true, provider: provider }
        elsif result[:rate_limited]
          LOG.info "#{provider} rate limited — next"
          next
        else
          LOG.warn "#{provider} failed: #{result[:output].lines.last(3).join}"
          git("reset --hard #{head_sha}")
          return { success: false, reason: result[:output] }
        end
      end

      git("reset --hard #{head_sha}")
      { success: false, reason: "all providers exhausted" }
    end

    private

    def call_aider(provider)
      cmd = %W[aider --yes --no-auto-commits --no-pretty
               --model #{provider} --message-file #{@prompt_file}]
      stdout, stderr, status = Open3.capture3(*cmd, chdir: REPO_PATH)
      output = stdout + stderr
      {
        success:      status.success? && !output.match?(/error|traceback/i),
        rate_limited: output.match?(/429|rate.?limit/i),
        output:       output
      }
    end

    def git(cmd)
      `git -C #{REPO_PATH} #{cmd}`
    end
  end
end
