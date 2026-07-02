# frozen_string_literal: true
# Builds the context hash passed to PromptBuilder.
#
# Load order (matches prompt injection order):
#   1. stack.yml       — runtime environment, gems, versions
#   2. schema.yml      — full schema always; filtered to relevant models when identifiable
#   3. conventions.yml — naming, patterns, canonical code shapes
#   4. testing.yml     — fixture catalogue, what to test, forbidden patterns
#   5. decisions.yml   — append-only architecture decisions with implementation notes
#   6. source_files    — existing source files that the issue will touch (fetched live)
#
# schema.yml filtering:
#   Attempts to match model names from issue title+body (PascalCase → snake_case lookup).
#   Falls back to injecting the FULL schema if no match found.
#   A partial schema is worse than no schema — never return nil silently.
#
# source_files injection:
#   Scans the issue body for a "## Source Files" section listing paths (one per line).
#   Falls back to heuristic detection: any path-like token ending in .rb found in the
#   issue title+body is fetched from the target repo.
#   Files that do not exist (404) are silently skipped.
#   Fetched files are injected verbatim so the model sees the real current content
#   and never has to reconstruct it from memory.

require "yaml"
require "octokit"

module Calvin
  class ContextBuilder
    STATIC_FILES = %i[stack schema conventions testing decisions].freeze

    # Well-known files to always fetch when the issue touches auth, users, or routes.
    ALWAYS_FETCH = %w[
      backend/api/config/routes.rb
      backend/api/app/models/user.rb
      backend/api/app/models/application_record.rb
      backend/api/app/controllers/application_controller.rb
    ].freeze

    def self.build(issue, github_client: nil) = new(issue, github_client).build

    def initialize(issue, github_client = nil)
      @issue         = issue
      @github_client = github_client || default_github_client
      @target_repo   = ENV.fetch("GITHUB_REPOSITORY", nil)
    end

    def build
      ctx = {}
      ctx[:stack]        = read_file("stack")
      ctx[:schema]       = build_schema
      ctx[:conventions]  = read_file("conventions")
      ctx[:testing]      = read_file("testing")
      ctx[:decisions]    = read_file("decisions")
      ctx[:source_files] = fetch_source_files if @target_repo
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
    def build_schema
      path = File.join(calvin_dir, "schema.yml")
      unless File.exist?(path)
        return "# WARNING: schema.yml not found in #{calvin_dir}"
      end

      raw    = File.read(path)
      schema = YAML.safe_load(raw) || {}

      candidates = extract_table_names
      matched    = candidates.select { |t| schema.key?(t) }

      if matched.any?
        matched.each_with_object({}) { |t, h| h[t] = schema[t] }.to_yaml
      else
        raw
      end
    end

    # Fetches existing source files from the target repo so the model sees real
    # current content instead of reconstructing it from memory.
    #
    # Priority order:
    #   1. Paths listed under "## Source Files" section in the issue body
    #   2. .rb path tokens found anywhere in title+body
    #   3. ALWAYS_FETCH well-known files (routes.rb, user.rb, etc.)
    #
    # Returns a Hash { path => content } or nil if nothing was fetched.
    def fetch_source_files
      paths = (explicit_source_paths + heuristic_paths + ALWAYS_FETCH).uniq
      return nil if paths.empty?

      result = {}
      paths.each do |path|
        content = fetch_github_file(path)
        result[path] = content if content
      end

      result.empty? ? nil : result
    end

    # Paths explicitly listed under a "## Source Files" or "## Files" section
    # in the issue body, one path per line (with or without leading `-` or `*`).
    def explicit_source_paths
      body = @issue.body.to_s
      section = body[/^##\s+Source Files?(.+?)(?=^##|\z)/mi, 1]
      return [] unless section

      section.lines
             .map { |l| l.strip.sub(/\A[-*]\s*/, "") }
             .select { |l| l.match?(/\A\S+\.rb\z/) }
    end

    # Scans issue title + body for tokens that look like Ruby file paths.
    def heuristic_paths
      text = "#{@issue.title} #{@issue.body}"
      text.scan(/(?:backend\/api\/)?(?:app|config|test|lib)\/[\w\/.]+\.rb/)
          .map { |p| p.start_with?("backend/") ? p : "backend/api/#{p}" }
          .uniq
    end

    def fetch_github_file(path)
      content_obj = @github_client.contents(@target_repo, path: path)
      return nil unless content_obj.respond_to?(:content)

      require "base64"
      Base64.decode64(content_obj.content).force_encoding("UTF-8")
    rescue Octokit::NotFound
      nil
    rescue StandardError => e
      Calvin::LOG.warn "Could not fetch #{path}: #{e.message}"
      nil
    end

    def default_github_client
      token = ENV.fetch("GITHUB_TOKEN", ENV.fetch("SYNCA_TOKEN", nil))
      return nil unless token

      Octokit::Client.new(access_token: token)
    end

    def extract_table_names
      text = "#{@issue.title} #{@issue.body}"

      pascal_words = text.scan(/\b[A-Z][a-z]+(?:[A-Z][a-z]+)+\b/)
      snake_direct = text.scan(/\b[a-z][a-z_]+(?:_[a-z]+)+\b/)

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
