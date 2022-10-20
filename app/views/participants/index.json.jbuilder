json.array!(@participants) do |participant|
  json.extract! participant, :id, :project_id, :user_id
  json.url participant_url(participant, format: :json)
end
