puts "RACK TIMEOOOOOOOOOOOOOOOOOOOOOOOUT"

Rails.application.middleware.use Rack::Timeout
Rack::Timeout.timeout = 10000  # seconds

