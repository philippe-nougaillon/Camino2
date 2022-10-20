json.array!(@todos) do |todo|
  json.extract! todo, :id, :name, :project_id, :user_id, :done
  json.url todo_url(todo, format: :json)
end
