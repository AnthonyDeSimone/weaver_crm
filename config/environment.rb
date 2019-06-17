# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.default_url_options = { :host => 'http://weaver-crm.herokuapp.com/' }
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.raise_delivery_errors = true

    
ActionMailer::Base.smtp_settings = {
  :address              => 'smtp.sendgrid.net',
  :port                 => '587',
  :authentication       => :plain,
  :user_name            => ENV['SENDGRID_USERNAME'],
  :password             => ENV['SENDGRID_PASSWORD'],
  :domain               => 'heroku.com',
  :enable_starttls_auto => true
}
  
=begin
Rails.application.config.action_mailer.smtp_settings = {
  :address   => "smtp.mandrillapp.com",
  :port      => 25,
  :user_name => 'anthony@mydesignforest.com',
  :password  => 'eAe6pbMv9EdK_TR9ArNokw'
}
=end

