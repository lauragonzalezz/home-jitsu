source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.12"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.0"

# Propshaft serves precompiled assets; JS is bundled by jsbundling (webpack)
# and CSS by cssbundling (sass), both emitting into app/assets/builds.
gem "propshaft"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Ruby 3.4 dropped csv from the default gems, so declare it explicitly.
# Pulled in transitively (e.g. geocoder) and would otherwise fail to load.
gem "csv"

# The Solid trifecta: database-backed Action Cable, Active Job and cache,
# all on the primary Postgres database. This removes the Redis dependency
# so production can run on free tiers without a separate Redis service.
gem "solid_cable"
gem "solid_queue"
gem "solid_cache"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Bundle and process CSS (Sass) into app/assets/builds [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem "geocoder"
gem "simple_form", github: "heartcombo/simple_form"
group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "dotenv-rails"
end

group :development do
  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Pin to the 5.x series: Rails 7.1 is built against minitest 5, and minitest
  # 6 changed Runnable#run's arity, which breaks railties' line filtering.
  gem "minitest", "~> 5.25"

  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end

gem "devise", "~> 4.9"
gem "faker"
gem "pundit"
gem "cloudinary"
gem "noticed", "~> 2.0"
