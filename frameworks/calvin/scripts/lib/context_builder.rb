# frozen_string_literal: true
# Builds the context hash passed to PromptBuilder.
#
# Load order (matches prompt injection order):
#   1. stack.yml       — runtime environment, gems, versions
#   2. schema.yml      — full schema always; filtered to relevant models when identifiable
#   3. conventions.yml — naming, patterns, canonical code shapes
#   4. testing.yml     — fixture catalogue, what to test, forbidden patterns
#   5. decisions.yml   — append-only architecture decisions with implementation notes
#
# schema.yml filtering:
#   Attempts to match model names from issue title+body (PascalCase → snake_case lookup).
#   Falls back to injecting the FULL schema if no match found.
#   A partial schema is worse than no schema — never return nil silently.

require "yaml"

module Calvin
  class ContextBuilder
    STATIC_FILES = %i[stack schema conventions testing decisions].freeze

    def self.build(issue) = new(issue).build

    def initialize(issue)
      @issue = issue
    end

    def build
      ctx = {}
      ctx[:stack]       = read_file("stack")
      ctx[:schema]      = build_schema
      ctx[:conventions] = read_file("conventions")
      ctx[:testing]     = read_file("testing")
      ctx[:decisions]   = read_file("decisions")
      ctx
    end

    private

    def calvin_dir
      ENV.fetch("CALVIN_DIR", File.join(Dir.pwd, ".calvin"))
    end

    def read_file(name)
      path = File.join(calvin_dir, "#{name}.yml")
      File.exist?(path) ? File.read(path) : nil
    end

    # Returns a filtered schema YAML string when model names are identifiable,
    # or the full schema YAML string as fallback.
    # Never returns nil — a missing/empty schema is surfaced as a warning string.
    def build_schema
      path = File.join(calvin_dir, "schema.yml")
      unless File.exist?(path)
        return "# WARNING: schema.yml not found in #{calvin_dir}"
      end

      raw    = File.read(path)
      schema = YAML.safe_load(raw) || {}

      # schema.yml top-level keys are snake_case table names (e.g. "spark_sessions").
      # Extract candidate table names from issue text by converting PascalCase → snake_case.
      candidates = extract_table_names
      matched    = candidates.select { |t| schema.key?(t) }

      if matched.any?
        matched.each_with_object({}) { |t, h| h[t] = schema[t] }.to_yaml
      else
        # No match: inject full schema so the model always has ground truth.
        raw
      end
    end

    # Scans issue title + body for PascalCase words and snake_case table-like words,
    # converts all to snake_case, deduplicates.
    def extract_table_names
      text = "#{@issue.title} #{@issue.body}"

      pascal_words = text.scan(/\b[A-Z][a-z]+(?:[A-Z][a-z]+)+\b/)  # SparkSession, MatchParticipant
      snake_direct = text.scan(/\b[a-z][a-z_]+(?:_[a-z]+)+\b/)     # spark_sessions, health_summaries

      converted = pascal_words.map { |w| pascal_to_snake(w) }
      (converted + snake_direct).map(&:downcase).uniq
    end

    def pascal_to_snake(str)
      str
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .downcase
    end
  end
end
