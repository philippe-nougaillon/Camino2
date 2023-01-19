# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins 'portfolio-philnoug.herokuapp.com', 'www.philnoug.com'
      resource '/about', headers: :any, methods: :get
    end
end