module AuditsHelper
  def prettify(audit)
    pretty_changes = []

    audit.audited_changes.each do |c|
      key = c.first.humanize
      if key == 'User'
        ids = audit.audited_changes['user_id']
        case ids.class.name
        when 'Integer'
          pretty_changes << "'#{key}' initialisé à '#{User.find(ids).email}'"
        when 'Array'
          pretty_changes << "'#{key}' changé de '#{User.find(ids.first).email if ids.first}' à '#{User.find(ids.last).email if ids.last}'"
        end
      elsif key == 'Contact'
        ids = audit.audited_changes['contact_id']
        begin
          case ids.class.name
          when 'Integer'
            pretty_changes << "'#{key}' initialisé à '#{Contact.find(ids).nom}'"
          when 'Array'
            pretty_changes << "'#{key}' changé de '#{Contact.find(ids.first).nom if ids.first}' à '#{Contact.find(ids.last).nom if ids.last}'"
          end
        rescue StandardError => e
          pretty_changes << "error: '#{e.message}'"
        end
      else
        if audit.action == 'update'
          unless c.last.first.blank? && c.last.last.blank?    
            pretty_changes << "'#{key}' modifié de '#{c.last.first}' à '#{c.last.last}'"
          end
        else 
          unless c.last.blank?
            pretty_changes << "'#{key}' #{audit.action == 'create' ? 'initialisé à' : 'était'} '#{c.last}'"
          end
        end
      end
    end
    pretty_changes
  end
end
