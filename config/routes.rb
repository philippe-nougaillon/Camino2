Rails.application.routes.draw do
  devise_for :users, controllers: { 
    omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  scope "/admin" do
    resources :users do
      member do
        get :icalendar
      end
    end
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
  delete 'documents/purge'

  get "agenda/index"

  get "show_attrs" => "tables#show_attrs" 

  resources :accounts, only: %i[ edit update ] do
    member do
      get :suppression_compte
      post :suppression_compte_do
    end
  end
  resources :comments, only: %i[ index create ]
  resources :templates
  resources :logs
  resources :todolists, except: :index
  resources :participants, only: %i[ edit update ]
  resources :todos, except: %i[ show ]
  resources :projects
  resources :tables
  resources :fields, only: %i[ edit update create destroy ]
  resources :mail_logs, only: %i[ index ]

  get 'tables/:id/fill' => 'tables#fill', as: :fill
  post 'tables/:id/fill' => 'tables#fill_do', as: :fill_do
  get 'tables/:id/link' => 'tables#link', as: :link
  post 'tables/:id/link' => 'tables#link_do', as: :link_do

  delete 'tables/:id/delete_record' => 'tables#delete_record', as: :delete_record

  get 'about', to: 'pages#about', as: :about
  get 'dashboard', to: 'pages#dashboard', as: :dashboard

  get 'audits/index'

  get '/service-worker.js' => "service_worker#service_worker"
  get '/manifest.json' => "service_worker#manifest"

  root 'projects#index'
end
