
source "https://rubygems.org"

gem "rails", "~> 8.1.4"

# Asset pipeline
gem "propshaft"

# PostgreSQL
gem "pg", "~> 1.1"

# Web server
gem "puma", ">= 5.0"

# Frontend: Hotwire and import maps
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

# Rails database-backed adapters
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Boot performance
gem "bootsnap", require: false

# Windows timezone support
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "rspec-rails"

  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Security checks
  gem "bundler-audit", require: false
  gem "brakeman", require: false

  # Ruby style checks
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end
