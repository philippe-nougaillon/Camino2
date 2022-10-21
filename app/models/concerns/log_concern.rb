# encoding: utf-8

module LogConcern
  extend ActiveSupport::Concern

  def log_changes(action_id, user_id)


    changes = if action_id == :delete 
      then Hash.new # comme changes est nil pour la suppression, on crée un hash vide 
      else self.changes 
    end

    #logger.debug "DEBUG #{changes}"

    #return unless changes.any?

    actions = {add:'ajouté', edit:'modifié', delete:'supprimé', comment:'commenté', document:'ajouté un document'}
    actions_values = {add:0, edit:1, delete:2, comment:3, document:4}
    action = actions[action_id]

    if changes.include?(:docfilename)
      changes.delete(:docfilename)
      changes.delete(:docname)
      action = "ajouté"
    end
    if changes.include?(:workflow)
      changes["Déroulement"] = changes.delete(:workflow)
      action = "modifié"
    end
    if changes.include?(:user_id)
      changes["Utilisateur"] = ["#{User.find(changes[:user_id].first).name if changes[:user_id].first}", "#{User.find(changes[:user_id].last).name if changes[:user_id].last}"]
      changes.delete(:user_id)
      action = "assigné"
    end
    if changes.include?(:color)
      changes["Couleur"] = changes.delete(:color)
      action = "modifié"
    end
    if changes.include?(:name) and action_id == :edit
      changes["Nom"] = changes.delete(:name)
      action = "renommé"
    end
    if changes.include?(:table_id)
      changes["Table"] = ["#{Table.find(changes[:table_id].first).name if changes[:table_id].first}", "#{Table.find(changes[:table_id].last).name if changes[:table_id].last}"]
      changes.delete(:table_id)
      action = "modifié"
    end
    if changes.include?(:notifydays)
      changes["Notification avant échéance"] = changes.delete(:notifydays)
      action = "modifié"
    end
    if changes.include?(:tag_list)
      changes["TAGS"] = changes.delete(:tag_list)
      action = "modifié"
    end
    if changes.include?(:duedate)
      changes["Echéance"] = ["#{I18n.l(changes[:duedate].first) if changes[:duedate].first }" , "#{I18n.l(changes[:duedate].last) if changes[:duedate].last }"]
      changes.delete(:duedate)
      action = "modifié"
    end
    if changes.include?(:done) and action_id == :edit
      action = "terminé" if changes[:done].last == true # if todo.done 
      action = "ré-ouvert" if changes[:done].last == false # if !todo.done
      changes.delete(:done) # remove this hash key from changes 
    end
    if self.new_record? and action_id == :add
      action = "ajouté"
    end      
 
    logger.debug "DEBUG Action:#{action}"

    quoi = case self.class.name
      when 'Project' then 
        "le projet <a href='/projects/#{self.id}'>'#{self.name}'</a>"
      when 'Todolist' then
        unless action_id == :delete
          "<a href='todolists/#{self.id}'>'#{self.name}'</a> #{action_id==:add ? 'au' : 'du'} projet <a href='/projects/#{self.project.id}'>'#{self.project.name}'</a>"
        else
          "<b>'#{self.name}'</b> du projet <a href='/projects/#{self.project.id}'>'#{self.project.name}'</a>"
        end
      when 'Todo' then 
        case action_id
        when :delete
          "<a href='/todos/#{self.id}/edit'>'#{self.name}'</a> du projet <a href='/todolists/#{self.todolist.id}'>'#{self.project.name}:#{self.todolist.name}'</a>"
        when :document
          "<a href='/documents/#{self.docfilename}'>'#{self.docname}'</a> à <a href='/todos/#{self.id}/edit'>'#{self.name}'</a> du projet <a href='/todolists/#{self.todolist.id}'>'#{self.project.name}:#{self.todolist.name}</a>'"
        else
          "<b>'#{self.name}'</b> #{action_id==:add ? 'au' : 'du'} projet <a href='/todolists/#{self.todolist.id}'>'#{self.project.name}:#{self.todolist.name}'</a>"
        end
      when 'Comment' then 
        "'<b>#{self.texte}</b>' sur <a href='/todos/#{self.todo.id}/edit'>'#{self.todo.name}'</a> #{action_id==:add ? 'au' : 'du'} projet <a href='/todolists/#{self.todolist.id}'>'#{self.project.name}:#{self.todolist.name}'</a>"
    end

    user = User.find(user_id)

    msg = "#{action} #{quoi}"
    msg += " #{changes}" if action_id ==:edit and changes.any? # show changes 


   logger.debug "DEBUG msg:#{msg}"


    unless action.blank? and changes.any?
      case self.class.name
        when 'Project' then 
          Log.create(project_id:self.id, todolist_id:nil, user_id:user.id, description:msg, action_id:actions_values[action_id])
        when 'Todolist' then
          Log.create(project_id:self.project.id, todolist_id:self.id, user_id:user.id, description:msg, action_id:actions_values[action_id])
        when 'Todo', 'Comment' then 
          Log.create(project_id:self.project.id, todolist_id:self.todolist.id, user_id:user.id, description:msg, action_id:actions_values[action_id])
      end

     logger.debug "DEBUG Log:#{Log.first.inspect}"

     if action_id != :add
        # notify all participants by sending update emails
        log = Log.first
        if log.project.participants.notification_subcribers.any?
          Notifier.update(log).deliver_later
        end 
        
        if action == "terminé"
          # notify all clients by sending update emails
          log.project.participants.where(client:true).each do |participant|
            Notifier.update_client(log, participant).deliver_later
          end 
        end    

        if action == "commenté" and (self.audience == 2 or self.audience == 0) # envoi le commentaire au client si audience = client ou tous
          # notify all clients by sending update emails
          log.project.participants.where(client:true).each do |participant|
            Notifier.update_client(log, participant).deliver_later
          end 
        end
      end    
    end
  end

end

