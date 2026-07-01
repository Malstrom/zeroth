# frozen_string_literal: true
# Assembla il prompt testuale per Mistral (analisi) o aider (implementazione).

module Calvin
  class PromptBuilder
    def self.build_for_mistral(issue, context) = new(issue, context).build_for_mistral
    def self.build_for_aider(issue, context)   = new(issue, context).build_for_aider

    # Compatibilità retroattiva
    def self.build(issue, context) = build_for_aider(issue, context)

    def initialize(issue, context)
      @issue   = issue
      @context = context
    end

    # Prompt per Mistral: analisi, piano, rischi. Niente codice, niente XML.
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

    # Prompt per aider: implementazione completa con path espliciti dei file da creare.
    def build_for_aider
      parts = context_parts
      parts << "\n## Issue ##{@issue.number}: #{@issue.title}\n\n#{@issue.body}\n"
      parts << <<~DIRECTIVE

        ## Implementation directive

        You are aider. Fully implement everything in the issue above.
        Write all code now. Do not analyse, do not suggest — implement.

        Rules:
        - Follow the conventions and stack in the Context section.
        - Create every missing file at the exact path shown below.
        - Edit every existing file that needs to change.
        - Write a Minitest test for every new endpoint or public method.
        - No TODO comments — implement everything completely.

        ## Files to create or edit

        Based on the issue, you MUST create/edit these files:
        #{file_list_for_issue}

        ## Calvin notes
        Add a `## Calvin notes` section in the PR body with:
        - patterns to add to conventions.yml
        - decisions to add to decisions.yml
      DIRECTIVE
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

    # Deduce i path dei file da creare/modificare dal titolo e body dell'issue.
    # Regole semplici per Rails API: controller, route, test.
    def file_list_for_issue
      title = @issue.title.downcase
      body  = @issue.body.to_s.downcase
      text  = "#{title} #{body}"

      lines = []

      # Cerca mention di controller (es. "health", "users", ecc.)
      controller_names = text.scan(/([a-z_]+)_controller|controller\s+([a-z_]+)/).flatten.compact.uniq
      controller_names += text.scan(/`([a-z_]+)#/).flatten

      # Fallback: estrae la prima parola significativa dopo "add", "create", "implement"
      if controller_names.empty?
        controller_names = text.scan(/(?:add|create|implement)\s+(?:a\s+)?(?:get\s+\/[\w\/]+\/)?([a-z_]+)/).flatten
      end

      controller_names.uniq.each do |name|
        lines << "- backend/api/app/controllers/api/v1/#{name}_controller.rb (create)"
        lines << "- backend/api/test/controllers/api/v1/#{name}_controller_test.rb (create)"
      end

      lines << "- backend/api/config/routes.rb (edit)"

      lines.empty? ? "(determine from the issue above)" : lines.join("\n")
    end
  end
end
