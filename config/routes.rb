Rails.application.routes.draw do
  devise_for :users
  resources :users, except: [:destroy]
  
  get "sitemap" => "sitemap#show", format: :xml, as: :sitemap

  get 'users/:id/login' => 'users#login'

  get 'invite' => 'projects#invite' 
  post 'invite' => 'projects#send_invitation' 
  get 'accepter' => 'projects#accepter' 

  get 'forgot_password' => 'users#forgot_password' 
  post 'forgot_password' => 'users#forgot_password' 

  post 'todos/:id/close' => 'todos#close'
  post 'todos/:id/reopen' => 'todos#reopen'

  get 'projects/:id/save_as_template' => 'projects#save_as_template'
  post 'projects/:id/save_as_template' => 'projects#save_as_template_post'

  get 'projects/:id/archive' => 'projects#archive'

  get 'documents/index'

  get "agenda/index"
  get 'admin' => "admin/index"

  get "show_attrs" => "tables#show_attrs" 

  get "/images/close",  to: redirect("images/close.png") 

  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
    get 'logout' => :destroy
  end

  resources :accounts
  resources :comments
  resources :templates
  resources :logs
  resources :todolists
  resources :participants
  resources :todos
  resources :users
  resources :projects
  resources :tables
  resources :values
  resources :fields

  get 'tables/:id/fill' => 'tables#fill', as: :fill
  post 'tables/:id/fill' => 'tables#fill_do', as: :fill_do

  delete 'tables/:id/delete_record' => 'tables#delete_record', as: :delete_record

  get 'about', to: 'pages#about', as: :about

  get 'audits/index'

  root 'projects#index'
end
