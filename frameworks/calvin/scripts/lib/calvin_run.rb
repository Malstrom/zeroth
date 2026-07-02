# frozen_string_literal: true
# Value object che rappresenta una singola esecuzione Calvin.
# Usato dall'orchestratore in calvin.rb.

CalvinRun = Struct.new(
  :issue,          # Octokit issue object
  :context,        # Hash { conventions:, stack:, decisions:, schema: }
  :mistral_prompt, # String — prompt per Mistral/Codestral
  :notes,          # String — risposta LLM in markdown (flusso commento)
  :generated_code, # String — codice grezzo generato da Codestral (flusso aider)
  :branch,         # String — nome branch creato per questa issue (flusso aider)
  :pr_url,         # String — URL della PR aperta (flusso aider)
  :ci_passed,      # Boolean — esito CI (flusso aider)
  keyword_init: true
)
