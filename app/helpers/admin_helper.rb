module AdminHelper
  def account_infos(account)
    # total_audit = account.audits.count
    total_lignes = 1
    account.users.each do |user|
      # total_audit += user.audits.count
      total_lignes += 1
      user.participants.each do |participant|
        # total_audit += participant.audits.count
        total_lignes += 1
      end
    end
    account.templates.each do |template|
      # total_audit += template.audits.count
      total_lignes += 1
    end
    account.mail_logs.each do |mail_log|
      # total_audit += mail_log.audits.count
      total_lignes += 1
    end
    account.projects.each do |project|
      # total_audit += project.audits.count
      total_lignes += 1
      project.logs.each do |log|
        total_lignes += 1
      end
      project.todolists.each do |todolist|
        # total_audit += todolist.audits.count
        total_lignes += 1
        todolist.todos.each do |todo|
          # total_audit += todo.audits.count
          total_lignes += 1
          todo.comments.each do |comment|
            # total_audit += comment.audits.count
            total_lignes += 1
          end
        end
      end
    end
    account.tables.each do |table|
      # total_audit += table.audits.count
      total_lignes += 1
      table.fields.each do |field|
        # total_audit += field.audits.count
        total_lignes += 1
        field.values.each do |value|
          # total_audit += value.audits.count
          total_lignes += 1
        end
      end
    end
    return total_lignes
  end
end
