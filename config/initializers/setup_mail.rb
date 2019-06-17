ActionMailer::Base.delivery_method  = :smtp
ActionMailer::Base.smtp_settings    = {
  address:              'smtp.sendgrid.net',
  port:                 '587',
  authentication:       :plain,
  user_name:            'app30874668@heroku.com',
  password:             '1dlpxogn',
  domain:               'heroku.com',
  enable_starttls_auto: true
}

