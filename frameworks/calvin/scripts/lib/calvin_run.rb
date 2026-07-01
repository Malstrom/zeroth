# frozen_string_literal: true
# Value object che rappresenta una singola esecuzione Calvin.
# Usato dall'orchestratore in calvin.rb.

CalvinRun = Struct.new(
  :issue,          # Octokit issue object
  :context,        # Hash { conventions:, stack:, decisions:, schema: }
  :mistral_prompt, # String — prompt per Mistral
  :notes,          # String — risposta Mistral in markdown
  keyword_init: true
)
