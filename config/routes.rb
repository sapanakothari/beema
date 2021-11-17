# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # Almost every application defines a route for the root path ("/") at the top of this file.
  root to: 'vehicles#index'

  get 'vehicles/export', to: 'vehicles#export', as: 'export_vehicles'
  post 'vehicles/import', to: 'vehicles#import', as: 'import_vehicles'
  get 'vehicles/search', to: 'vehicles#search', as: 'search_vehicles'
end
