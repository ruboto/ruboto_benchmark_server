RubotoStartupServer::Application.routes.draw do
  resources :startups
  root :to => "startups#index"
end
