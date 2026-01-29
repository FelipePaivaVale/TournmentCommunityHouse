# frozen_string_literal: true

# Compatibility shim for gems that still call Sprockets::Environment#load_path
# (removed in Sprockets 4). This maps to the current `paths` API.
if defined?(Sprockets::Environment) && !Sprockets::Environment.method_defined?(:load_path)
  Sprockets::Environment.class_eval do
    def load_path
      paths
    end
  end
end