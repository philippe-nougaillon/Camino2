class MailLog < ApplicationRecord
  audited

  belongs_to :account

  default_scope {order('mail_logs.created_at DESC')} 
end
