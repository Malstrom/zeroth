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
#   Attempts to match model names from issue title+body (PascalCase -> snake_case lookup).
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
      Calvin::LOG.info "Context dir: #{calvin_dir}"

      ctx = {}
      ctx[:stack]        = load_static(:stack)
      ctx[:schema]       = build_schema
      ctx[:conventions]  = load_static(:conventions)
      ctx[:testing]      = load_static(:testing)
      ctx[:decisions]    = load_static(:decisions)
      ctx[:source_files] = fetch_source_files if @target_repo

      log_summary(ctx)
      ctx
    end

    private

    def calvin_dir
      ENV.fetch("CALVIN_DIR", File.join(Dir.pwd, ".calvin"))
    end

    def load_static(name)
      path = File.join(calvin_dir, "#{name}.yml")
      if File.exist?(path)
        Calvin::LOG.info "  [context] #{name}.yml ✅ loaded (#{File.size(path)} bytes)"
        File.read(path)
      else
        Calvin::LOG.warn "  [context] #{name}.yml ⚠️  not found — skipped"
        nil
      end
    end

    # Returns a filtered schema YAML string when model names are identifiable,
    # or the full schema YAML string as fallback.
    def build_schema
      path = File.join(calvin_dir, "schema.yml")
      unless File.exist?(path)
        Calvin::LOG.warn "  [context] schema.yml ⚠️  not found — skipped"
        return nil
      end

      raw    = File.read(path)
      schema = YAML.safe_load(raw) || {}

      candidates = extract_table_names
      matched    = candidates.select { |t| schema.key?(t) }

      if matched.any?
        Calvin::LOG.info "  [context] schema.yml ✅ loaded — filtered to: #{matched.join(', ')}"
        matched.each_with_object({}) { |t, h| h[t] = schema[t] }.to_yaml
      else
        Calvin::LOG.info "  [context] schema.yml ✅ loaded — no model match, injecting full schema (#{raw.bytesize} bytes)"
        raw
      end
    end

    # Fetches existing source files from the target repo so the model sees real
    # current content instead of reconstructing it from memory.
    def fetch_source_files
      explicit  = explicit_source_paths
      heuristic = heuristic_paths
      always    = ALWAYS_FETCH

      Calvin::LOG.info "  [context] source_files — explicit: #{explicit.size}, heuristic: #{heuristic.size}, always_fetch: #{always.size}"

      paths = (explicit + heuristic + always).uniq
      return nil if paths.empty?

      result = {}
      skipped = []

      paths.each do |path|
        content = fetch_github_file(path)
        if content
          result[path] = content
          Calvin::LOG.info "  [context]   ✅ #{path} (#{content.bytesize} bytes)"
        else
          skipped << path
        end
      end

      Calvin::LOG.warn "  [context]   ⚠️  skipped (not found): #{skipped.join(', ')}" if skipped.any?
      Calvin::LOG.info "  [context] source_files: #{result.size} loaded, #{skipped.size} skipped"

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

    def log_summary(ctx)
      loaded  = ctx.reject { |_, v| v.nil? }.keys
      missing = ctx.select { |_, v| v.nil? }.keys
      Calvin::LOG.info "[context] loaded: #{loaded.join(', ')}"
      Calvin::LOG.warn "[context] missing: #{missing.join(', ')}" if missing.any?
    end
  end
end
