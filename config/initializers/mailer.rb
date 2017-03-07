# make sure we the environment variables have been set

#  ENV['JOBLINGE_HOST'],                 #Ex: https://www.myapp.com
#  ENV['JOBLINGE_EMAIL_ADDRESS'],        #Ex: smtp.gmail.com
#  ENV['JOBLINGE_EMAIL_PORT'],           #Ex: 587
#  ENV['JOBLINGE_EMAIL_AUTHENTICATION'], #Ex: :plain
#  ENV['JOBLINGE_EMAIL_DOMAIN'],         #Ex: gmail.com
#  ENV['JOBLINGE_EMAIL_USER'],           #Ex: foo@gmail.com
#  ENV['JOBLINGE_EMAIL_PASSWORD'],       #Ex: qwerty

url_options = {
  'development' => {:host => "localhost"},
  'test'        => {:host => "localhost"},
  'production'  => {:host => ENV['JOBLINGE_HOST'] },
}

Rails.application.config.default_url_options = url_options[Rails.env]
Rails.application.config.action_mailer.asset_host = url_options[Rails.env][:host]
ActionMailer::Base.default_url_options = url_options[Rails.env]
ActionMailer::Base.default from: "JOBLINGE <#{ENV['JOBLINGE_EMAIL_DEFAULT_FROM']}>"

def mailcatcher_configuration
  ActionMailer::Base.perform_deliveries    = true
  ActionMailer::Base.delivery_method       = :smtp
  ActionMailer::Base.smtp_settings         = { :address => "localhost", :port => 1025 }
  ActionMailer::Base.raise_delivery_errors = true
end

def configuration_for_environment
  case Rails.env
  when "test"
    ActionMailer::Base.perform_deliveries    = true
    ActionMailer::Base.raise_delivery_errors = true
    ActionMailer::Base.delivery_method       = :test
  when "development"
    mailcatcher_configuration
  when "production"
    ActionMailer::Base.perform_deliveries    = true
    ActionMailer::Base.delivery_method       = :smtp
    ActionMailer::Base.raise_delivery_errors = true
    ActionMailer::Base.smtp_settings         = {
      :address              => ENV['JOBLINGE_EMAIL_ADDRESS'].presence,
      :port                 => ENV['JOBLINGE_EMAIL_PORT'].presence,
      :authentication       => ENV['JOBLINGE_EMAIL_AUTHENTICATION'].presence,
      :domain               => ENV['JOBLINGE_EMAIL_DOMAIN'].presence,
      :user_name            => ENV['JOBLINGE_EMAIL_USER'].presence,
      :password             => ENV['JOBLINGE_EMAIL_PASSWORD'].presence,
      :enable_starttls_auto => true,
    }.compact
  end
end

if ENV['JOBLINGE_USE_MAILCATCHER'].presence && !Rails.env.test?
  mailcatcher_configuration
else
  configuration_for_environment
end
