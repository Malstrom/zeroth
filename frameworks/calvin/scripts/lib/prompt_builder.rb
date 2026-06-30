# frozen_string_literal: true
# Assembla il prompt testuale che viene passato ad aider.
# Include contesto .calvin/ + titolo/body dell'issue.

module Calvin
  class PromptBuilder
    def self.build(issue, context) = new(issue, context).build

    def initialize(issue, context)
      @issue   = issue
      @context = context
    end

    def build
      parts = ["## Context\n"]

      # Aggiunge conventions, stack e decisions se presenti
      %i[conventions stack decisions].each do |key|
        parts << "### #{key}\n```yaml\n#{@context[key]}\n```\n" if @context[key]
      end

      # Aggiunge schema filtrato per questa issue
      if @context[:schema]
        parts << "### schema (relevant models only)\n```yaml\n#{@context[:schema].to_yaml}```\n"
      end

      # L'issue stessa: titolo + body completo
      parts << "\n## Issue ##{@issue.number}: #{@issue.title}\n\n#{@issue.body}\n"

      # Istruzioni per Calvin notes nella PR
      parts << "\n## Calvin notes\n"
      parts << "Add a `## Calvin notes` section in the PR body with:\n"
      parts << "- patterns to add to conventions.yml\n"
      parts << "- decisions to add to decisions.yml\n"
      parts.join
    end
  end
end
