RubotoStartupServer::Application.routes.draw do
  match "/startups/top_ten" => "startups#top_ten"
  match "/measurements/top_ten" => "measurements#top_ten"

  resources :measurements

  match '/startups/new' => 'startups#new'
  post '/startups' => 'startups#create'
  match '/startups' => 'startups#index'

  root :to => "measurements#index"
end
