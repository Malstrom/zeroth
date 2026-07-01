# frozen_string_literal: true
# Client per Mistral API.
# .complete(prompt)        → String (analisi/note in markdown)
# .generate_files(prompt)  → Array<{path:, content:}> (implementazione)

require "net/http"
require "json"

module Calvin
  class MistralClient
    API_URL   = URI("https://api.mistral.ai/v1/chat/completions")
    MODEL     = "mistral-small-latest"
    MODEL_CODE = "codestral-latest"

    def initialize(api_key: ENV.fetch("MISTRAL_API_KEY"))
      @api_key = api_key
    end

    # Analisi in markdown — usato per le note nell'issue/PR.
    def complete(prompt)
      call(prompt, model: MODEL)
    end

    # Genera i file da scrivere nel repo.
    # Ritorna Array<Hash> con :path e :content.
    # Usa Codestral e forza risposta JSON.
    def generate_files(prompt)
      system_prompt = <<~SYS
        You are a senior Rails developer implementing a GitHub issue.
        Reply with ONLY a JSON array. No markdown, no explanation, no code fences.
        Each element: { "path": "relative/path/to/file.rb", "content": "full file content" }
        Paths are relative to the repository root.
        Include every file that needs to be created or modified.
      SYS

      raw = call(prompt, model: MODEL_CODE, system: system_prompt)

      # Strip accidental markdown fences if model disobeys
      raw = raw.gsub(/```json\s*/i, "").gsub(/```\s*/, "").strip

      JSON.parse(raw).map { |f| { path: f["path"], content: f["content"] } }
    rescue JSON::ParserError => e
      raise "Mistral returned invalid JSON: #{e.message}\n\nRaw:\n#{raw}"
    end

    private

    def call(prompt, model:, system: nil)
      http = Net::HTTP.new(API_URL.host, API_URL.port)
      http.use_ssl = true

      messages = []
      messages << { role: "system", content: system } if system
      messages << { role: "user",   content: prompt }

      req = Net::HTTP::Post.new(API_URL)
      req["Content-Type"]  = "application/json"
      req["Authorization"] = "Bearer #{@api_key}"
      req.body = { model: model, messages: messages }.to_json

      resp = http.request(req)
      raise "Mistral error: #{resp.code} #{resp.body}" unless resp.is_a?(Net::HTTPSuccess)

      JSON.parse(resp.body).dig("choices", 0, "message", "content")
    end
  end
end
