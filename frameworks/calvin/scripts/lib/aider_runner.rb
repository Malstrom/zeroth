# frozen_string_literal: true
# Wrapper per Aider CLI.
# Riceve il prompt della issue e lascia che Aider legga il repo-map,
# generi il codice e scriva i file autonomamente.
#
# --no-auto-commits: Aider scrive i file ma non committa.
# Calvin fa git add + commit + push dopo il CI verde.

require "open3"

module Calvin
  class AiderRunner
    AIDER_MODEL = "codestral/codestral-latest"

    def initialize(api_key: ENV.fetch("MISTRAL_API_KEY"))
      @api_key = api_key
    end

    # Passa il prompt ad Aider. Aider legge il repo-map, decide quali file
    # creare o modificare, genera il codice e lo scrive su disco.
    # Ritorna true se il comando esce con status 0, false altrimenti.
    def apply(prompt)
      env = { "CODESTRAL_API_KEY" => @api_key }

      cmd = [
        "aider",
        "--model",           AIDER_MODEL,
        "--yes",
        "--no-auto-lint",
        "--no-auto-commits",
        "--message",         prompt
      ]

      Calvin::LOG.info "Running aider (#{AIDER_MODEL})..."
      stdout, stderr, status = Open3.capture3(env, *cmd)
      Calvin::LOG.info stdout unless stdout.empty?
      Calvin::LOG.warn stderr unless stderr.empty?
      status.success?
    end
  end
end
