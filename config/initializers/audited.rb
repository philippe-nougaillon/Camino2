Rails.configuration.to_prepare do 
  ActiveStorage::Attachment.audited associated_with: :record
  ActiveStorage::Blob.audited
end

Audited.max_audits = 2 # keep only 10 latest audits