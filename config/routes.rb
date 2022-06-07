Spree::Core::Engine.add_routes do
  # Add your extension routes here
  namespace :admin do
    resource :graffiti_settings do
      collection do
        post :clear_cache
      end
    end
  end
end
