Rails.application.routes.draw do
  devise_for :users, :controllers => { registrations: 'users/registrations' }

  
  get "sitemap" => "sitemap#show", format: :xml, as: :sitemap

  get 'invite' => 'projects#invite' 
  post 'invite' => 'projects#send_invitation' 
  get 'accepter' => 'projects#accepter' 

  post 'todos/:id/close' => 'todos#close'
  post 'todos/:id/reopen' => 'todos#reopen'

  get 'projects/:id/save_as_template' => 'projects#save_as_template'
  post 'projects/:id/save_as_template' => 'projects#save_as_template_post'

  get 'projects/:id/archive' => 'projects#archive'

  get 'documents/index'

  get "agenda/index"
  get "agenda/export_icalendar"

  get 'admin' => "admin/index"

  get "show_attrs" => "tables#show_attrs" 

  get "/images/close",  to: redirect("images/close.png") 

  resources :accounts
  resources :comments
  resources :templates
  resources :logs
  resources :todolists
  resources :participants
  resources :todos
  resources :projects
  resources :tables
  resources :users
  resources :values
  resources :fields

  get 'tables/:id/fill' => 'tables#fill', as: :fill
  post 'tables/:id/fill' => 'tables#fill_do', as: :fill_do

  delete 'tables/:id/delete_record' => 'tables#delete_record', as: :delete_record

  get 'about', to: 'pages#about', as: :about
  get 'dashboard', to: 'pages#dashboard', as: :dashboard

  get 'audits/index'

  root 'projects#index'
end
