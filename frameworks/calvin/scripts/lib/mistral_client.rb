# frozen_string_literal: true
# Client minimale per chiamare Mistral direttamente.
# Usa l'API chat completions con il payload che hai indicato.

require "net/http"
require "json"

module Calvin
  class MistralClient
    API_URL = URI("https://api.mistral.ai/v1/chat/completions")

    def initialize(api_key: ENV.fetch("MISTRAL_API_KEY"))
      @api_key = api_key
    end

    # Prende il prompt (stringa) e ritorna il contenuto della risposta.
    def complete(prompt)
      http = Net::HTTP.new(API_URL.host, API_URL.port)
      http.use_ssl = true

      req = Net::HTTP::Post.new(API_URL)
      req["Content-Type"]  = "application/json"
      req["Authorization"] = "Bearer #{@api_key}"

      req.body = {
        model: "mistral-small-latest",
        messages: [
          { role: "user", content: prompt }
        ]
      }.to_json

      resp = http.request(req)

      unless resp.is_a?(Net::HTTPSuccess)
        raise "Mistral error: #{resp.code} #{resp.body}"
      end

      data = JSON.parse(resp.body)
      data.dig("choices", 0, "message", "content")
    end
  end
end
