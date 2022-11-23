Rails.application.routes.draw do
  devise_for :users, :controllers => { registrations: 'users/registrations' }
  scope "/admin" do
    resources :users
  end

  get "sitemap" => "sitemap#show", format: :xml, as: :sitemap

  get 'invite' => 'projects#invite' 
  post 'invite' => 'projects#invite_do' 
  get 'accepter' => 'projects#accepter' 

  post 'todos/:id/close' => 'todos#close'
  post 'todos/:id/reopen' => 'todos#reopen'

  get 'projects/:id/save_as_template' => 'projects#save_as_template'
  post 'projects/:id/save_as_template' => 'projects#save_as_template_post'

  get 'documents/index'

  get "agenda/index"
  get "agenda/export_icalendar"

  get "show_attrs" => "tables#show_attrs" 

  get "/images/close",  to: redirect("images/close.png") 

  resources :accounts, only: %i[ edit update ]
  resources :comments
  resources :templates
  resources :logs
  resources :todolists, except: :index
  resources :participants, only: %i[ edit update ]
  resources :todos
  resources :projects
  resources :tables
  resources :values
  resources :fields, only: %i[ edit update create destroy ]

  get 'tables/:id/fill' => 'tables#fill', as: :fill
  post 'tables/:id/fill' => 'tables#fill_do', as: :fill_do

  delete 'tables/:id/delete_record' => 'tables#delete_record', as: :delete_record

  get 'about', to: 'pages#about', as: :about
  get 'dashboard', to: 'pages#dashboard', as: :dashboard

  get 'audits/index'

  root 'projects#index'
end
