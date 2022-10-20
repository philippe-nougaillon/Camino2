json.array!(@todolists) do |todolist|
  json.extract! todolist, :id, :project_id, :name
  json.url todolist_url(todolist, format: :json)
end
