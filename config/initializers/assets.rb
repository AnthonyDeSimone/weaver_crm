# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w( radmin-green.css )
#Rails.application.config.assets.precompile += %w( google_maps_api.js )
Rails.application.config.assets.precompile += %w( Chart.min.js )
Rails.application.config.assets.precompile += %w( bootstrap.min.js )
Rails.application.config.assets.precompile += %w( '.woff', '.eot', '.svg', '.ttf' )
Rails.application.config.assets.precompile += %w( expand.css )
