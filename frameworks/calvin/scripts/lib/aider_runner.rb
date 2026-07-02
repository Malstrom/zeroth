# frozen_string_literal: true
# Wrapper per Aider CLI.
# Usa il provider nativo Codestral di Aider (codestral/codestral-latest).
# Richiede solo MISTRAL_API_KEY nell'env.

require "open3"

module Calvin
  class AiderRunner
    # Provider nativo Aider per Codestral — non richiede OPENAI_API_KEY
    AIDER_MODEL = "codestral/codestral-latest"

    def initialize(api_key: ENV.fetch("MISTRAL_API_KEY"))
      @api_key = api_key
    end

    # Applica il codice generato da Codestral sul branch corrente.
    # code_message — stringa con blocchi ```ruby ... ``` prodotti da MistralClient#generate_code
    # Ritorna true se il comando esce con status 0, false altrimenti.
    def apply(code_message)
      env = {
        "CODESTRAL_API_KEY" => @api_key
      }

      cmd = [
        "aider",
        "--model",        AIDER_MODEL,
        "--yes",
        "--no-auto-lint",
        "--message",      code_message
      ]

      Calvin::LOG.info "Running aider (#{AIDER_MODEL})..."
      stdout, stderr, status = Open3.capture3(env, *cmd)
      Calvin::LOG.info stdout unless stdout.empty?
      Calvin::LOG.warn stderr unless stderr.empty?
      status.success?
    end
  end
end
