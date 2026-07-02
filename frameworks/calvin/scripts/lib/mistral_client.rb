# frozen_string_literal: true
# Client per Mistral / Codestral API.
# Modello selezionato tramite variabile d'ambiente CALVIN_MODEL:
#   mistral-medium-3   → flusso commento (label: agent)
#   codestral-latest   → flusso aider (label: agent-aider)
#
# .complete(prompt)   → String (markdown)
# .fix_ci(prompt, ci) → String (prompt arricchito per Aider, solo se errore non è di ambiente)

require "net/http"
require "json"

module Calvin
  class MistralClient
    API_URL       = URI("https://api.mistral.ai/v1/chat/completions")
    DEFAULT_MODEL = ENV.fetch("CALVIN_MODEL", "mistral-medium-3")

    OPEN_TIMEOUT = 15
    READ_TIMEOUT = 180

    # Pattern che identificano errori non risolvibili da Aider toccando il codice.
    # Tipicamente: ambiente CI mal configurato, schema DB non allineato, dipendenze mancanti.
    # In questi casi non ha senso fare un secondo tentativo — Aider non può fixare infrastruttura.
    ENV_ERROR_PATTERNS = [
      # Ambiente / configurazione Rails
      /HMAC key expected to be a String/i,
      /Rails\.application\.credentials/i,
      /SECRET_KEY_BASE/i,
      /can't find executable/i,
      /railties is not currently included/i,
      /RAILS_MASTER_KEY/i,
      # Database non raggiungibile o non esistente
      /database.*does not exist/i,
      /connection refused.*postgres/i,
      /PG::ConnectionBad/i,
      /ActiveRecord::NoDatabaseError/i,
      # Schema DB non allineato: enum punta a colonna mancante.
      # Aider non può creare una migration senza contesto completo — blocchiamo il loop.
      /Undeclared attribute type for enum/i,
      /Enums must be backed by a database column/i,
      /column .* does not exist/i,
      /PG::UndefinedColumn/i,
      /ActiveRecord::StatementInvalid.*column/i
    ].freeze

    def initialize(api_key: ENV.fetch("MISTRAL_API_KEY"))
      @api_key = api_key
    end

    # Risposta markdown — usata dal flusso commento (label: agent)
    def complete(prompt)
      call(prompt, model: DEFAULT_MODEL)
    end

    # Genera una patch di fix dato l'output di CI fallito.
    # Se l'output contiene errori di ambiente o schema, restituisce il prompt
    # originale invariato — non ha senso mandare Aider a toccare il codice.
    def fix_ci(original_prompt, ci_output)
      if environment_error?(ci_output)
        Calvin::LOG.warn "fix_ci: CI failure is an environment/schema error — skipping Aider fix pass"
        Calvin::LOG.warn "fix_ci: pattern matched in output: #{matched_env_patterns(ci_output).join(', ')}"
        return original_prompt
      end

      fix_prompt = <<~PROMPT
        The following CI output shows failing tests or errors in the code.
        These are NOT environment/configuration errors — they are real code bugs.
        Fix only the files needed to make the tests pass.
        Do not change unrelated files.

        ## Rails 8 rules — MUST follow
        - Use `default:` NOT `_default:`. Example:
            enum :account_type, { guest: 0, active: 1 }, default: :guest
          The option key is `default:` (without underscore). `_default:` is INVALID and will raise ArgumentError.
        - Never pass unknown keys to `enum`. Valid options are: :prefix, :suffix, :scopes, :default, :instance_methods, :validate.
        - NEVER add an `enum` to a model without also creating the corresponding migration.
          If you add `enum :foo` to a model, you MUST create a migration that adds column `foo` to the table.
        - Do NOT add columns/attributes to existing models unless the issue explicitly requires it.

        ## Original task
        #{original_prompt}

        ## CI failure output
        ```
        #{ci_output.slice(0, 8_000)}
        ```
      PROMPT

      Calvin::LOG.info "fix_ci: building Aider fix prompt for code errors"
      fix_prompt
    end

    private

    def environment_error?(ci_output)
      ENV_ERROR_PATTERNS.any? { |pattern| ci_output.match?(pattern) }
    end

    def matched_env_patterns(ci_output)
      ENV_ERROR_PATTERNS.select { |p| ci_output.match?(p) }.map(&:source)
    end

    def call(prompt, model:, system: nil)
      http              = Net::HTTP.new(API_URL.host, API_URL.port)
      http.use_ssl      = true
      http.open_timeout = OPEN_TIMEOUT
      http.read_timeout = READ_TIMEOUT

      messages = []
      messages << { role: "system", content: system } if system
      messages << { role: "user",   content: prompt }

      req                  = Net::HTTP::Post.new(API_URL)
      req["Content-Type"]  = "application/json"
      req["Authorization"] = "Bearer #{@api_key}"
      req.body             = { model: model, messages: messages }.to_json

      resp = http.request(req)
      raise "Mistral error: #{resp.code} #{resp.body}" unless resp.is_a?(Net::HTTPSuccess)

      JSON.parse(resp.body).dig("choices", 0, "message", "content")
    end
  end
end
