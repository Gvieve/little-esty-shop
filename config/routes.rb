Rails.application.routes.draw do

  namespace :admin do
    resources :merchants, except: [:destroy]
    resources :invoices, only: [:index, :update, :show]
    get '', to: 'dashboard#index', as: '/'
  end

  resources :merchant do
    resources :dashboard, only: [:index]
    resources :items, except: [:destroy]
    resources :items_status, controller: 'merchant_items', only: [:update]
    resources :invoices, only: [:index, :show]
    resources :bulk_discounts
  end

  resources :invoice_items, only: [:update]
  get '/', to: 'welcome#index'
end
