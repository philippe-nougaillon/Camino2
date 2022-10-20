json.extract! user, :id, :name, :username, :picturelink, :created_at, :updated_at
json.url user_url(user, format: :json)
