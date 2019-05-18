Rails.application.routes.draw do
  namespace :api, defaults: {format: 'json'} do
    resources :messages, only: [:create, :show]
  end
end
