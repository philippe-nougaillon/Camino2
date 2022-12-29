Rails.configuration.to_prepare do 
  ActiveStorage::Attachment.audited associated_with: :record
  ActiveStorage::Blob.audited
end