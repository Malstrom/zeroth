# frozen_string_literal: true
# Assembla il prompt testuale che viene passato a Mistral.
# Include contesto .calvin/ + titolo/body dell'issue.

module Calvin
  class PromptBuilder
    def self.build(issue, context)             = new(issue, context).build
    def self.build_for_mistral(issue, context) = new(issue, context).build
    def self.build_for_aider(issue, context)   = new(issue, context).build

    def initialize(issue, context)
      @issue   = issue
      @context = context
    end

    def build
      parts = ["## Context\n"]

      %i[conventions stack decisions].each do |key|
        parts << "### #{key}\n```yaml\n#{@context[key]}\n```\n" if @context[key]
      end

      if @context[:schema]
        parts << "### schema (relevant models only)\n```yaml\n#{@context[:schema].to_yaml}```\n"
      end

      parts << "\n## Issue ##{@issue.number}: #{@issue.title}\n\n#{@issue.body}\n"

      parts << "\n## Calvin notes\n"
      parts << "Add a `## Calvin notes` section in the PR body with:\n"
      parts << "- patterns to add to conventions.yml\n"
      parts << "- decisions to add to decisions.yml\n"
      parts.join
    end
  end
end
