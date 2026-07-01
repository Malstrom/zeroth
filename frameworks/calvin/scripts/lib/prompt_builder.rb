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

      # Direttiva esplicita per aider: implementa tutto, non solo analizzare
      parts << <<~DIRECTIVE

        ## Implementation directive

        You are aider, an AI coding assistant. Your job is to fully implement
        everything described in the issue above. Do NOT just analyse or suggest —
        write all the code, create every file, and make every change needed so
        the acceptance criteria are completely satisfied.

        Rules:
        - Create every file that is missing (controllers, models, serializers, tests, etc.).
        - Edit every existing file that needs to change (routes, initializers, etc.).
        - Follow the conventions and stack defined in the Context section above.
        - Write a Minitest test for every new public method / endpoint.
        - Do not leave TODO comments — implement everything now.
        - When done, all acceptance criteria in the issue must be met.
      DIRECTIVE

      # Istruzioni per Calvin notes nella PR
      parts << "\n## Calvin notes\n"
      parts << "Add a `## Calvin notes` section in the PR body with:\n"
      parts << "- patterns to add to conventions.yml\n"
      parts << "- decisions to add to decisions.yml\n"
      parts.join
    end
  end
end
