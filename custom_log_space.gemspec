# frozen_string_literal: true

require_relative "lib/custom_log_space/version"

Gem::Specification.new do |spec|
  spec.name = "custom_log_space"
  spec.version = CustomLogSpace::VERSION
  spec.authors = ["nishikawa1031"]
  spec.email = ["tatsunishitatsu@gmail.com"]

  spec.summary = "A Rails logger extension that organizes logs by controller and action into dedicated folders."
  spec.description = "CustomLogSpace refines Rails logs by categorizing them by controller and action. It provides a clearer view."
  spec.homepage = "https://github.com/nishikawa1031/custom_log_space.git"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nishikawa1031/custom_log_space.git"
  spec.metadata["changelog_uri"] = "https://github.com/nishikawa1031/custom_log_space/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_runtime_dependency "activesupport", ">= 6.0", "< 8.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
