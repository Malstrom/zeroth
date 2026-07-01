# frozen_string_literal: true
# Assembla il prompt testuale che viene passato a Mistral.
# Include contesto .calvin/ + titolo/body dell'issue.
# L'obiettivo è ottenere codice Ruby implementativo pronto per il review.

module Calvin
  class PromptBuilder
    def self.build(issue, context) = new(issue, context).build

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

      parts << <<~INSTRUCTIONS

        ## Task

        You are a senior Rails API developer. Implement the issue above.

        Produce **only Ruby code** — no prose explanations before or after.
        For every file that needs to be created or changed, output a fenced block:

        ```ruby
        # path: relative/path/from/repo/root.rb
        <full file content here>
        ```

        Include:
        - route entry in `backend/api/config/routes.rb` (show only the relevant lines with context)
        - controller
        - service / presenter if needed
        - request spec (RSpec)

        Follow the conventions and stack defined above.
        Do not include migrations unless the issue explicitly asks for schema changes.
      INSTRUCTIONS

      parts.join
    end
  end
end
