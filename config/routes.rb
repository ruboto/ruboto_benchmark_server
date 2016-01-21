Rails.application.routes.draw do
  resources :measurements do
    get :top_ten, on: :collection
  end

  get '/startups/new' => 'startups#new'
  post '/startups' => 'startups#create'
  get '/startups' => 'startups#index'

  get "/measurements_drilldown" => "measurements_drilldown#index"
  get "/measurements_drilldown/excel_export" => "measurements_drilldown#excel_export"
  get "/measurements_drilldown/html_export" => "measurements_drilldown#html_export"

  root to: "measurements#index"
end
