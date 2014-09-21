require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Testapp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      :address              => ENV['SMTP_ADDRESS'],
      :port                 => ENV['SMTP_PORT'].to_i,
      :domain               => ENV['SMTP_DOMAIN'],
      :user_name            => ENV['SMTP_USERNAME'],
      :password             => ENV['SMTP_PASSWORD'],
      :authentication       => ENV['SMTP_AUTH']
    }

    config.action_mailer.smtp_settings[:enable_starttls_auto] = true if ENV['SMTP_ENCRYPTION'] == 'starttls'
    config.action_mailer.smtp_settings[:ssl] = true if ENV['SMTP_ENCRYPTION'] == 'ssl'
    config.action_mailer.default_options = { from: ENV['ACTION_MAILER_DEFAULT_FROM'] }
    config.action_mailer.default_url_options = { host: ENV['ACTION_MAILER_HOST'] }

    config.cache_store = :redis_store, ENV['CACHE_URL'],
                         { namespace: 'testapp::cache' }

    # run `bundle exec rake time:zones:all` to get a complete list of valid time zone names
    config.time_zone = ENV['TIME_ZONE'] unless ENV['TIME_ZONE'] == 'UTC'

    # http://www.loc.gov/standards/iso639-2/php/English_list.php
    config.i18n.default_locale = ENV['DEFAULT_LOCALE'] unless ENV['DEFAULT_LOCALE'] == 'en'

    # Log everything to a single file.
    config.paths['log'] = ENV['LOG_FILE']

    # Rotate logs daily. This gets overwritten in staging/production by writing
    # to syslog instead of a log file. Rotating in development prevents your
    # log file from getting out of control in size.
    config.logger = Logger.new(config.paths['log'].first, 'daily')

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  if html_tag =~ /\<label/
    html_tag
  else
    errors = Array(instance.error_message).join(',')
    %(#{html_tag}<p class="validation-error"> #{errors}</p>).html_safe
  end
end
