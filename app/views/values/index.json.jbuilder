json.array!(@values) do |value|
  json.extract! value, :id, :field_id, :data
  json.url value_url(value, format: :json)
end
