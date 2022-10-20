json.array!(@comments) do |comment|
  json.extract! comment, :id, :todo_id, :user_id, :texte
  json.url comment_url(comment, format: :json)
end
