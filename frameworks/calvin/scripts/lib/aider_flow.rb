# frozen_string_literal: true
# Gestisce il flusso agent-aider:
# branch → Aider(prompt) → CI loop → commit → push → PR → commento issue

module Calvin
  class AiderFlow
    MAX_CI_RETRIES = 2

    def initialize(github, issue, prompt)
      @github = github
      @issue  = issue
      @prompt = prompt
    end

    def run
      setup_branch

      aider  = AiderRunner.new
      ci     = CiRunner.new
      llm    = MistralClient.new
      passed = false

      MAX_CI_RETRIES.times do |attempt|
        Calvin::LOG.info "Aider apply — attempt #{attempt + 1}"
        aider.apply(@prompt)

        result = ci.run
        if result.passed
          passed = true
          Calvin::LOG.info "CI passed on attempt #{attempt + 1}"
          break
        else
          Calvin::LOG.warn "CI failed attempt #{attempt + 1}, building fix prompt..."
          @prompt = llm.fix_ci(@prompt, result.output)
        end
      end

      commit_changes
      push_branch
      pr_url = PrBuilder.new.open(branch: @branch, issue: @issue)
      @github.post_status(@issue, status_comment(passed, pr_url))
    end

    private

    def setup_branch
      slug    = @issue.title.downcase.gsub(/[^a-z0-9]+/, "-").slice(0, 40).chomp("-")
      @branch = "feat/#{slug}-#{@issue.number}"
      system("git checkout -b #{@branch}") or raise "git checkout failed"
      Calvin::LOG.info "Branch: #{@branch}"
    end

    def commit_changes
      system("git add -A")
      committed = system("git commit -m 'feat: implement ##{@issue.number} via Calvin/Aider'")
      Calvin::LOG.info committed ? "Committed changes" : "Nothing to commit"
    end

    def push_branch
      repo_url = "https://x-access-token:#{ENV.fetch('GITHUB_TOKEN')}@github.com/#{Calvin::REPO}.git"
      system("git remote set-url origin #{repo_url}")
      system("git push origin #{@branch} --force-with-lease") or raise "git push failed"
    end

    def status_comment(passed, pr_url)
      icon  = passed ? "\u{1F7E2}" : "\u{1F534}"
      label = passed ? "CI passed" : "CI failed after #{MAX_CI_RETRIES} attempts"
      "<!-- calvin-status -->\n**Calvin** \u00B7 `#{@branch}`\n#{icon} #{label} \u00B7 [PR aperta](#{pr_url})"
    end
  end
end
