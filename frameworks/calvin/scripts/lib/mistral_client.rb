# frozen_string_literal: true
# Client per Mistral / Codestral API.
# Modello selezionato tramite variabile d'ambiente CALVIN_MODEL:
#   mistral-medium-3   → commento sull'issue (default)
#   codestral-latest   → modalità aider (generazione codice)
#
# .complete(prompt)       → String (markdown)
# .generate_code(prompt)  → String (blocchi ruby grezzi, passati ad Aider)

require "net/http"
require "json"

module Calvin
  class MistralClient
    API_URL      = URI("https://api.mistral.ai/v1/chat/completions")
    DEFAULT_MODEL = ENV.fetch("CALVIN_MODEL", "mistral-medium-3")

    OPEN_TIMEOUT = 15
    READ_TIMEOUT = 180

    def initialize(api_key: nil)
      @api_key = api_key ||
                 ENV["CODESTRAL_API_KEY"] ||
                 ENV.fetch("MISTRAL_API_KEY")
    end

    # Risposta markdown — usata dal flusso commento (label: agent)
    def complete(prompt)
      call(prompt, model: DEFAULT_MODEL)
    end

    # Genera codice grezzo da passare ad Aider come messaggio.
    # Ritorna la stringa raw (blocchi ```ruby ... ```) senza parsing.
    def generate_code(prompt)
      system_prompt = <<~SYS
        You are a senior Rails 8 developer implementing a GitHub issue.
        Output ONLY fenced ruby code blocks, one per file.
        First line of each block must be a comment with the file path:
          # path: relative/path/from/repo/root.rb
        No prose before or after the code blocks.
      SYS
      call(prompt, model: DEFAULT_MODEL, system: system_prompt)
    end

    # Genera una patch di fix dato l'output di CI fallito.
    # Ritorna la stessa forma di generate_code.
    def fix_ci(prompt, ci_output)
      fix_prompt = <<~PROMPT
        The following CI output shows failing tests or errors.
        Fix the code to make CI pass. Output ONLY the corrected files
        in the same fenced ruby block format (# path: ... as first comment).
        Do not output files that do not need changes.

        ## Original task
        #{prompt}

        ## CI failure output
        ```
        #{ci_output.slice(0, 8_000)}
        ```
      PROMPT
      generate_code(fix_prompt)
    end

    private

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
      raise "Mistral/Codestral error: #{resp.code} #{resp.body}" unless resp.is_a?(Net::HTTPSuccess)

      JSON.parse(resp.body).dig("choices", 0, "message", "content")
    end
  end
end
