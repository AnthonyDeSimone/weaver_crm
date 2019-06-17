Rails.application.routes.draw do
  resources :service_tickets

  devise_for :salespeople, :controllers => {:invitations => 'salespeople/invitations'}
  devise_for :admins
  devise_for :installs
  
  devise_scope :salespeople do
    get "/login" => "devise/sessions#new"
  end

  devise_scope :salespeople do
    delete "/logout" => "devise/sessions#destroy"
  end  
    
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'reports#dashboard'

  #API Testing
  get '/styles' => 'application#styles'
  get '/features' => 'application#features'
  get '/sizes' => 'application#sizes'
  get '/styles_with_images' => 'application#styles_with_images'
  get '/prices' => 'application#prices'
  get '/prebuilt_available' => 'application#prebuilt_available'
  get '/finishable' => 'application#finishable'
  get '/doors' => 'application#doors'

  post '/components' => 'application#components'
  get '/components' => 'application#components'
  match '/components', to: 'application#preflight', via: [:options]  
  
  get '/new_components' => 'application#new_components'

  post '/calculate_price' => 'application#calculate_price'
  match 'calculate_price', to: 'application#preflight', via: [:options]
  
  post '/test' => 'application#test'
  get '/test' => 'application#test'
  get '/customers/search' => 'customers#search'
  get '/customers/hot' => 'customers#hot'
  get '/salespeople/inactive' => 'salespeople#inactive_index'
  get '/salespeople/team' => 'salespeople#show_by_team'
  post '/salespeople/:id/deactivate' => 'salespeople#deactivate'
  post '/salespeople/:id/reactivate' => 'salespeople#reactivate'
  post '/sales_teams/:id/deactivate' => 'sales_teams#deactivate'
  post '/sales_teams/:id/reactivate' => 'sales_teams#reactivate'

  post '/customer_comment/create/:id' => 'customer_comment#create'
  post '/customer_comment/:id/destroy' => 'customer_comment#destroy'
 
  get '/sales_orders/map' => 'sales_orders#google_map'

  get '/sales_orders/closed' => 'sales_orders#closed_index'
  get '/sales_orders/inactive' => 'sales_orders#inactive_index'
  post '/sales_orders/:id/follow_ups' => 'sales_orders#follow_ups'
  post '/sales_orders/:id/mail_invoice' => 'sales_orders#mail_invoice'
  post '/sales_orders/:id/mail_dropbox' => 'sales_orders#mail_dropbox'
  post '/sales_orders/:id/site_ready' => 'sales_orders#site_ready'
  get '/sales_orders/search' => 'sales_orders#search'  
  get '/customers/search' => 'customers#search'  
  
  post '/service_tickets/:id/mark_complete' => 'service_tickets#mark_complete'  
  post '/service_tickets/:id/confirm' => 'service_tickets#confirm'  
    
  get '/fishbowl_settings' => 'settings#index'

  get '/reports' => 'reports#index'
  get '/opportunities' => 'customers#opportunities'
  
  get '/index' => 'application#index'

  match '/sales_orders/save', to: 'application#preflight', via: [:options]
  post'/sales_orders/save' => 'sales_orders#save'       
  
  post'/sales_orders/:id/confirm' => 'sales_orders#confirm'  

  get '/sales_orders/comparison/:id' => 'sales_orders#comparison'      
  
  get '/edit_components' => 'application#edit_components'
  get '/edit_component_images' => 'application#edit_component_images'
  post'/edit_components' => 'application#update_components'
  get '/sales_orders/:id/load' => 'sales_orders#load_order'
  get '/customer/:id/load' => 'sales_orders#load_customer'
  get '/sales_orders/:id/confirmation' => 'sales_orders#confirmation'
  get '/sales_orders/:id/copy' => 'sales_orders#copy'
  
  get '/floor_plan' => 'sales_orders#floor_plan'
  
  post '/edit_image' => 'application#edit_image'

  get '/sales_orders/image_editor/component/:id.png' => 'component#image_proxy'
  get '/sales_orders/image_editor/component_option/:id.png' => 'component_option#image_proxy'

  get '/sales_orders/:order_id/image_editor/component/:id.png' => 'component#image_proxy'
  get '/sales_orders/:order_id/image_editor/component_option/:id.png' => 'component_option#image_proxy'

  get '/image_editor/component/:id.png' => 'component#image_proxy'
  get '/image_editor/component_option/:id.png' => 'component_option#image_proxy'

  get '/sales_orders/image_editor/component/:id' => 'component#image_proxy'
  get '/sales_orders/image_editor/component_option/:id' => 'component_option#image_proxy'

  get '/sales_orders/:order_id/image_editor/component/:id' => 'component#image_proxy'
  get '/sales_orders/:order_id/image_editor/component_option/:id' => 'component_option#image_proxy'
  
  get '/image_editor/component/:id.png' => 'component#image_proxy'
  get '/image_editor/component_option/:id.png' => 'component_option#image_proxy'

  get '/image_editor/component/:id' => 'component#image_proxy'
  get '/image_editor/component_option/:id' => 'component_option#image_proxy'
  
  get '/sales_orders/:id/production_order' => 'sales_orders#production_order'
  get '/sales_orders/production_order/:id' => 'sales_orders#production_order'
  
  get '/sales_orders_by_dealer/:id' => 'sales_orders#sales_orders_by_dealer'
  get '/sales_orders_by_dealer' => 'sales_orders#sales_orders_by_dealer'
  get '/sales_orders/export' => 'sales_orders#export_to_dropbox'
  post '/sales_orders/:id/approve' => 'sales_orders#approve'
  post '/sales_orders/:id/unapprove' => 'sales_orders#unapprove'
  get '/sales_orders/demo_units' => 'sales_orders#demo_units_orders'
  get '/sales_orders/:id/modify_prices' => 'sales_orders#modify_prices'
  post '/sales_orders/:id/update_prices' => 'sales_orders#update_prices'
  
  get '/customers/index/:id' => 'customers#index'
  
  get '/upload_barn_csv' => 'application#upload_barn_csv'
  post '/update_barn_csv' => 'application#update_barn_csv'
  
  post '/sales_orders/:id/close' => 'sales_orders#close'
  post '/sales_orders/:id/open' => 'sales_orders#open'
  
  post '/sales_orders/:id/finalize' => 'sales_orders#finalize'
  post '/sales_orders/:id/unfinalize' => 'sales_orders#unfinalize'
  
  get '/sales_orders/recent' => 'sales_orders#recent'
  get '/sales_orders/fishbowl' => 'sales_orders#fishbowl'
  
  post '/sales_orders/:id/fishbowl_finalize' => 'sales_orders#fishbowl_finalize'
  
  get '/sales_orders/final_approval' => 'sales_orders#final_approval_index'
  get '/sales_orders/:id/final_approval' => 'sales_orders#final_approval_form'
  
  post '/sales_orders/:id/final_approval' => 'sales_orders#final_approval'
  
  
  post '/sales_orders/:id/contact_date' => 'sales_orders#set_last_contact_date'
  post '/sales_orders/:id/callback_date' => 'sales_orders#set_callback_date'
  
  post '/sales_orders/:id/activate' => 'sales_orders#activate'
  post '/sales_orders/:id/deactivate' => 'sales_orders#deactivate'
  
  get '/sales_orders/:id/special_order' => 'sales_orders#special_order_form'
  post '/sales_orders/:id/submit_special_order' => 'sales_orders#submit_special_order'
  
  get '/sales_orders/quotes' => 'sales_orders#quote_index'
  get '/sales_orders/prebuilt_status' => 'sales_orders#prebuilt_status'
  get '/sales_orders/aos_status' => 'sales_orders#aos_status'
  post '/sales_orders/:id/production_complete' => 'sales_orders#production_complete'
  
  get '/sales_orders/general_search' => 'sales_orders#general_search'
  post '/sales_orders/double_approval' => 'sales_orders#double_approval'
  get '/sales_orders/:id/notes' => 'sales_orders#get_notes'
  get '/sales_orders/:id/warnings' => 'sales_orders#get_warnings'
  
  post '/test_email' => 'sales_orders#test_email'
  
  post '/sales_orders/:id/push_to_fishbowl' => 'sales_orders#push_to_fishbowl'
  
  get '/service_tickets/:id/load' => 'service_tickets#load_ticket'
  match '/service_tickets/save', to: 'application#preflight', via: [:options]  
  post '/service_tickets/save' => 'service_tickets#save'
  post '/sales_orders/push_to_dropbox' => 'sales_orders#push_to_dropbox'
  
  post '/sales_orders/:id/change_build_status/:status' => 'sales_orders#change_build_status'
  
  get '/infusionsoft_settings' => 'sales_teams#edit_infusionsoft_settings'
  post '/infusionsoft_settings' => 'sales_teams#update_infusionsoft_settings'
  
  post '/sales_orders/:id/in_use' => 'sales_orders#in_use'
  
  get '/sales_orders/:id/change_log' => 'sales_orders#change_log'
    
  resources :customers
  resources :sales_orders
  resources :customer_comment
  resources :sales_teams
  resources :salespeople
  resources :settings
  resources :service_tickets
  resources :component_categories
  resources :special_order_items, only: [:index]

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
