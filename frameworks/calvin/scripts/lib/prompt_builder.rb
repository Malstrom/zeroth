# frozen_string_literal: true
# Assembles the final prompt passed to the LLM (Mistral/Codestral).
#
# Context injection order:
#   1. stack       — versions, gems, Rails 8 features in use
#   2. schema      — DB ground truth (filtered or full)
#   3. conventions — naming, canonical patterns, do-not-touch rules
#   4. testing     — fixture catalogue, what to always test, forbidden patterns
#   5. decisions   — architecture decisions with implementation signatures
#   6. issue       — number, title, full body
#
# This order ensures the model has ground truth (stack, schema) before
# reading the pattern rules, and has the full decision rationale before
# reading the issue task.

module Calvin
  class PromptBuilder
    CONTEXT_ORDER = %i[stack schema conventions testing decisions].freeze

    CONTEXT_LABELS = {
      stack:       "Stack & Versions",
      schema:      "Database Schema (ground truth)",
      conventions: "Conventions & Canonical Patterns",
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

      parts << <<~ROLE
        You are a senior Rails 8 API developer working on the Synca backend.
        You have full context about the project below. Read it carefully before writing any code.

      ROLE

      parts << "## Project Context\n\n"

      CONTEXT_ORDER.each do |key|
        next unless @context[key]

        label = CONTEXT_LABELS[key]
        parts << "### #{label}\n\n```yaml\n#{@context[key].to_s.strip}\n```\n\n"
      end

      parts << issue_section
      parts << instructions

      parts.join
    end

    private

    def issue_section
      <<~ISSUE
        ---

        ## Issue \##{@issue.number}: #{@issue.title}

        #{@issue.body.to_s.strip}

      ISSUE
    end

    def instructions
      <<~TASK
        ---

        ## Task

        Implement the issue above following the conventions, stack, and decisions in the context.

        ### Output format

        Produce **only Ruby code** — no prose explanations before or after the code blocks.
        For every file to create or modify, output a fenced block with the path as first line comment:

        ```ruby
        # path: backend/api/relative/path/from/repo/root.rb
        # full file content here — never partial, never truncated
        ```

        ### Required files (include all that apply)

        - `backend/api/config/routes.rb` — show the full resources block with only relevant additions
        - Controller under `app/controllers/api/v1/`
        - Contract under `app/contracts/` (dry-validation)
        - Service under `app/services/` (interactor pattern, Result = Data.define)
        - Serializer under `app/serializers/` (Alba)
        - Minitest tests under `test/` — use the fixture catalogue from the Testing context above.
          Do NOT use RSpec. Do NOT use FactoryBot unless fixtures cannot cover the case.

        ### Hard constraints

        - Do NOT generate migrations unless the issue explicitly says "add migration" or "schema change".
        - Do NOT call MatchScoringFacade or MlEventLogger — they do not exist yet (V2).
        - Do NOT use params.require/permit — use the contract pattern.
        - Do NOT render json: directly — use ApiResponse helpers.
        - All FK columns must point to users.id, never profiles.id.
        - Enum syntax: `enum :field, { value: integer }` (Rails 8 modern syntax).
        - Every new file starts with `# frozen_string_literal: true`.
      TASK
    end
  end
end
