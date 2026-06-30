# frozen_string_literal: true
# Operazioni post-successo: aggiorna label, posta stato, torna su main.

module Calvin
  class Finalizer
    def self.finalize(issue, pr, result, github) = new(issue, pr, result, github).finalize

    def initialize(issue, pr, result, github)
      @issue  = issue
      @pr     = pr
      @result = result
      @github = github
    end

    def finalize
      # Sposta il label da agent → agent:review
      @github.set_labels(@issue, remove: "agent", add: "agent:review")

      # Posta il link alla PR sull'issue
      @github.post_status(@issue, "✅ PR ##{@pr.number} — #{@result[:model]}")

      # Torna su main per lasciare il repo pulito
      `git checkout main`

      LOG.info "##{@issue.number} done — PR ##{@pr.number}"
    end
  end
end
