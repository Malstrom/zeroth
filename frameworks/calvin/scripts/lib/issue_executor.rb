# frozen_string_literal: true
# Orchestratore principale per una singola issue.
# Sequenza: costruisce contesto → prompt Mistral (analisi) + prompt aider (implementazione) →
#           aider applica le modifiche → git commit/push → apre PR → posta link + note Mistral.

module Calvin
  class IssueExecutor
    # File sempre inclusi come contesto per aider (percorsi relativi alla root del repo target)
    BASE_CONTEXT_FILES = %w[
      backend/api/config/routes.rb
      backend/api/app/controllers/application_controller.rb
    ].freeze

    def initialize(issue, github)
      @issue               = issue
      @github              = github
      @mistral_prompt_file = "/tmp/calvin_mistral_#{issue.number}.txt"
      @aider_prompt_file   = "/tmp/calvin_aider_#{issue.number}.txt"
    end

    def run
      @github.post_status(@issue, "⏳ processing...")

      context = ContextBuilder.build(@issue)

      # Step 1: Mistral — solo analisi, prompt senza direttiva di implementazione
      mistral_prompt = PromptBuilder.build_for_mistral(@issue, context)
      File.write(@mistral_prompt_file, mistral_prompt)

      client   = MistralClient.new
      response = client.complete(mistral_prompt)
      LOG.info "Mistral response received (#{response&.length} chars)"

      # Step 2: aider — prompt con direttiva esplicita + file di contesto
      aider_prompt = PromptBuilder.build_for_aider(@issue, context)
      File.write(@aider_prompt_file, aider_prompt)

      context_files = resolve_context_files
      LOG.info "aider context files: #{context_files.join(', ')}"

      @github.post_status(@issue, "🤖 aider is working...")
      aider_result = AiderRunner.run(@aider_prompt_file, files: context_files)

      unless aider_result[:success]
        @github.post_status(@issue, "🚫 aider failed\n\n```\n#{aider_result[:reason]}\n```")
        return
      end

      LOG.info "aider succeeded with #{aider_result[:model]}"

      # Step 3: commit + push su branch dedicato
      branch      = "calvin/issue-#{@issue.number}"
      commit_info = GitCommitter.commit(@issue, branch)
      LOG.info "committed #{commit_info[:sha]} on #{commit_info[:branch]}"

      # Step 4: apre PR e posta link + note Mistral sull'issue
      pr = PullRequestOpener.open(@issue, commit_info, aider_result, @github)
      @github.post_status(@issue, "✅ Done! PR aperta: #{pr.html_url}\n\n---\n_Mistral notes:_\n\n#{response}")
    rescue StandardError => e
      @github.post_status(@issue, "🚫 error\n\n```\n#{e.message}\n#{e.backtrace.first(3).join("\n")}\n```")
      raise
    ensure
      FileUtils.rm_f(@mistral_prompt_file)
      FileUtils.rm_f(@aider_prompt_file)
    end

    private

    # Restituisce i file esistenti da passare ad aider come contesto.
    # Parte dai BASE_CONTEXT_FILES + cerca controller analoghi all'issue.
    def resolve_context_files
      files = BASE_CONTEXT_FILES.select { |f| File.exist?(f) }

      # Cerca controller già esistenti in app/controllers/api/v1/ come esempi di stile
      existing_controllers = Dir.glob("backend/api/app/controllers/api/v1/*.rb").first(3)
      files += existing_controllers

      # Cerca test esistenti come riferimento per lo stile dei test
      existing_tests = Dir.glob("backend/api/test/controllers/api/v1/*_test.rb").first(2)
      files += existing_tests

      files.uniq
    end
  end
end
