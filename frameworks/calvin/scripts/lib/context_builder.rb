# frozen_string_literal: true

module Calvin
  class ContextBuilder
    def self.build(issue) = new(issue).build

    def initialize(issue)
      @issue = issue
    end

    def build
      load_static_files.merge(schema: relevant_schema)
    end

    private

    def load_static_files
      %i[conventions stack decisions].each_with_object({}) do |name, hash|
        path = File.join(CALVIN_DIR, "#{name}.yml")
        hash[name] = File.read(path) if File.exist?(path)
      end
    end

    def relevant_schema
      schema_path = File.join(CALVIN_DIR, "schema.yml")
      return nil unless File.exist?(schema_path)

      schema  = YAML.safe_load(File.read(schema_path)) || {}
      models  = extract_model_names
      entries = models.filter_map { |m| [m, schema[m]] if schema[m] }
      entries.empty? ? nil : entries.to_h
    end

    def extract_model_names
      "#{@issue.title} #{@issue.body}".scan(/[A-Z][a-zA-Z]+/).uniq
    end
  end
end
