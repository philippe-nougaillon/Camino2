json.array!(@templates) do |template|
  json.extract! template, :id, :name, :project, :participants, :todolists, :todos
  json.url template_url(template, format: :json)
end
