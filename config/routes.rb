Rails.application.routes.draw do
  get "/startups/top_ten" => "startups#top_ten"
  get "/measurements/top_ten" => "measurements#top_ten"

  resources :measurements

  get '/startups/new' => 'startups#new'
  post '/startups' => 'startups#create'
  get '/startups' => 'startups#index'

  get "/measurements_drilldown" => "measurements_drilldown#index"
  get "/measurements_drilldown/excel_export" => "measurements_drilldown#excel_export"
  get "/measurements_drilldown/html_export" => "measurements_drilldown#html_export"

  root to: "measurements#index"
end
