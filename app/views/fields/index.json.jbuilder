json.array!(@fields) do |field|
  json.extract! field, :id, :name
  json.url field_url(field, format: :json)
end
