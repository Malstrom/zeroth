# frozen_string_literal: true
# Wrapper per Aider CLI.
# Aider viene invocato come subprocess sul repo già clonato (Dir.pwd = target/).
#
# Prerequisiti nel runner GitHub Actions:
#   - pip install aider-chat
#   - git config user.email / user.name impostati
#   - ANTHROPIC_API_KEY o OPENAI_API_KEY NON necessari:
#     usiamo --model openai/codestral-latest con --openai-api-base Mistral

require "open3"

module Calvin
  class AiderRunner
    AIDER_MODEL    = "openai/codestral-latest"
    AIDER_API_BASE = "https://api.mistral.ai/v1"
    MAX_RETRIES    = 2

    def initialize(api_key: nil)
      @api_key = api_key ||
                 ENV["CODESTRAL_API_KEY"] ||
                 ENV.fetch("MISTRAL_API_KEY")
    end

    # Applica il codice generato da Codestral sul branch corrente.
    # code_message — stringa con blocchi ```ruby ... ``` prodotti da MistralClient#generate_code
    # Ritorna true se il comando esce con status 0, false altrimenti.
    def apply(code_message)
      run_aider(code_message)
    end

    private

    def run_aider(message)
      cmd = [
        "aider",
        "--model",        AIDER_MODEL,
        "--openai-api-base", AIDER_API_BASE,
        "--openai-api-key",  @api_key,
        "--yes",           # nessuna conferma interattiva
        "--no-auto-lint",  # lint gestito da bin/rails ci
        "--message",      message
      ]

      Calvin::LOG.info "Running aider..."
      stdout, stderr, status = Open3.capture3(*cmd)
      Calvin::LOG.info stdout unless stdout.empty?
      Calvin::LOG.warn stderr unless stderr.empty?
      status.success?
    end
  end
end
