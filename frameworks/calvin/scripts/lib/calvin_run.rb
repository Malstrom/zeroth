# frozen_string_literal: true
# Value object che rappresenta una singola esecuzione Calvin.
# Viene costruito progressivamente dall'orchestratore in calvin.rb:
# ogni classe riceve il run, fa la sua trasformazione, e popola il proprio campo.

CalvinRun = Struct.new(
  :issue,          # Octokit issue object
  :context,        # Hash { conventions:, stack:, decisions:, schema: }
  :mistral_prompt, # String — prompt per Mistral (solo analisi)
  :aider_prompt,   # String — prompt per aider (implementazione completa)
  :notes,          # String — risposta Mistral in markdown
  :aider_result,   # Hash { success:, model: } oppure { success: false, reason: }
  :context_files,  # Array<String> — file passati ad aider con --file
  :commit,         # Hash { branch:, sha: }
  :pr,             # Octokit PR object
  keyword_init: true
)
