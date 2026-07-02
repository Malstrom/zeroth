# frozen_string_literal: true
# Assembla il prompt finale passato all'LLM o ad Aider.
#
# Nessun testo hardcodato — il contesto viene interamente dai file di progetto
# (.context.yml, schema.rb, ecc.) e dal corpo della issue stessa.
#
# Ordine di iniezione del contesto:
#   1. stack       — versioni, gem, features Rails 8 in uso
#   2. schema      — DB ground truth
#   3. conventions — naming, pattern canonici
#   4. testing     — fixture catalogue, regole di test
#   5. decisions   — decisioni architetturali
#   6. source_files — contenuto attuale dei file che la issue tocca
#   7. issue       — numero, titolo, corpo completo

module Calvin
  class PromptBuilder
    CONTEXT_ORDER = %i[stack schema conventions testing decisions].freeze

    CONTEXT_LABELS = {
      stack:       "Stack & Versions",
      schema:      "Database Schema",
      conventions: "Conventions & Patterns",
      testing:     "Testing Rules & Fixture Catalogue",
      decisions:   "Architecture Decisions"
    }.freeze

    def self.build(issue, context) = new(issue, context).build

    def initialize(issue, context)
      @issue   = issue
      @context = context
    end

    def build
      parts = []

      parts << "## Project Context\n\n"

      CONTEXT_ORDER.each do |key|
        next unless @context[key]
        label = CONTEXT_LABELS[key]
        parts << "### #{label}\n\n```yaml\n#{@context[key].to_s.strip}\n```\n\n"
      end

      if @context[:source_files]&.any?
        parts << "### Existing Source Files\n\n"
        @context[:source_files].each do |path, content|
          parts << "#### `#{path}`\n\n```ruby\n#{content.strip}\n```\n\n"
        end
      end

      parts << "---\n\n"
      parts << "## Issue \##{@issue.number}: #{@issue.title}\n\n"
      parts << @issue.body.to_s.strip
      parts << "\n"

      parts.join
    end
  end
end
