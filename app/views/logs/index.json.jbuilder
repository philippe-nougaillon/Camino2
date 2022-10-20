json.array!(@logs) do |log|
  json.extract! log, :id, :project_id, :todolist_id, :user_id, :description
  json.url log_url(log, format: :json)
end
