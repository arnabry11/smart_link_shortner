source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.0"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use Redis adapter to run Action Cable in production
gem "redis", ">= 4.0.1"
# Use Sidekiq as the Active Job backend
gem "sidekiq", "~> 8.0"
# Load environment variables from .env files
gem "dotenv-rails"
gem "strong_migrations"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# JWT Authentication with Warden
gem "warden-jwt_auth", "~> 0.12.0"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  gem "awesome_print", require: "ap"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rspec"
  gem "rspec-rails"
  gem "rspec-parameterized"
  gem "faker"
  gem "factory_bot_rails"
  gem "shoulda-matchers"
  gem "ruby-prof"
  gem "stackprof"
end

group :development do
  gem "brakeman"
  gem "foreman"
  gem "reek"
  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-thread_safety", require: false
  gem "rails_best_practices", require: false

  gem "binding_of_caller"
  gem "annotate"
  gem "bullet"
end

group :test do
  gem "database_cleaner-active_record"
  gem "rails-controller-testing"

  gem "codecov"
  gem "simplecov"
  gem "simplecov-cobertura"
  gem "simplecov-console"
  gem "vcr"
  gem "webmock"
  gem "test-prof"
  gem "timecop"
end
