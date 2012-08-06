RubotoStartupServer::Application.routes.draw do
  match "/startups/top_ten" => "startups#top_ten"
  match "/measurements/top_ten" => "measurements#top_ten"

  resources :measurements

  match '/startups/new' => 'startups#new'
  post '/startups' => 'startups#create'
  match '/startups' => 'startups#index'

  match "/measurements_drilldown" => "measurements_drilldown#index"
  match "/measurements_drilldown/excel_export" => "measurements_drilldown#excel_export"
  match "/measurements_drilldown/html_export" => "measurements_drilldown#html_export"

  root :to => "measurements#index"
end
