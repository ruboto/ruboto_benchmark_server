RubotoStartupServer::Application.routes.draw do
  match "/startups/top_ten" => "startups#top_ten"

  resources :startups

  root :to => "startups#index"
end
