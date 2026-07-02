# frozen_string_literal: true
# Gestisce il flusso agent:
# prompt → Mistral → commento markdown sull'issue

module Calvin
  class CommentFlow
    def initialize(github, issue, prompt)
      @github = github
      @issue  = issue
      @prompt = prompt
    end

    def run
      notes = MistralClient.new.complete(@prompt)

      comment = <<~MD
        <!-- calvin-status -->
        ## \u{1F4E4} Prompt inviato a Mistral

        <details><summary>Espandi prompt</summary>

        ```
        #{@prompt}
        ```

        </details>

        ---

        ## \u{1F916} Risposta Mistral

        #{notes}
      MD

      @github.post_status(@issue, comment)
      Calvin::LOG.info "##{@issue.number} done"
    end
  end
end
