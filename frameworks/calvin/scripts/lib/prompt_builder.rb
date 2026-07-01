# frozen_string_literal: true
# Assembla il prompt testuale per Mistral (analisi) o aider (implementazione).
# Usare PromptBuilder.build_for_mistral o PromptBuilder.build_for_aider.

module Calvin
  class PromptBuilder
    # Compatibilità con il vecchio singolo .build — ora alias di build_for_aider
    def self.build(issue, context) = build_for_aider(issue, context)

    def self.build_for_mistral(issue, context) = new(issue, context).build_for_mistral
    def self.build_for_aider(issue, context)   = new(issue, context).build_for_aider

    def initialize(issue, context)
      @issue   = issue
      @context = context
    end

    # Prompt per Mistral: solo contesto + issue. Risponde con analisi/note in markdown.
    # Non include mai la direttiva di implementazione — Mistral non è un executor.
    def build_for_mistral
      parts = context_parts
      parts << "\n## Issue ##{@issue.number}: #{@issue.title}\n\n#{@issue.body}\n"
      parts << <<~MISTRAL

        ## Your task

        Analyse this issue and reply in plain Markdown with:
        1. A brief implementation plan (which files to create/edit and why).
        2. Any conventions or architectural decisions worth noting.
        3. Potential risks or edge cases.

        Do NOT write code. Do NOT use XML tags or function calls. Plain Markdown only.
      MISTRAL
      parts.join
    end

    # Prompt per aider: contesto + issue + direttiva esplicita di implementazione completa.
    def build_for_aider
      parts = context_parts
      parts << "\n## Issue ##{@issue.number}: #{@issue.title}\n\n#{@issue.body}\n"
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

    private

    def context_parts
      parts = ["## Context\n"]
      %i[conventions stack decisions].each do |key|
        parts << "### #{key}\n```yaml\n#{@context[key]}\n```\n" if @context[key]
      end
      if @context[:schema]
        parts << "### schema (relevant models only)\n```yaml\n#{@context[:schema].to_yaml}```\n"
      end
      parts
    end
  end
end
