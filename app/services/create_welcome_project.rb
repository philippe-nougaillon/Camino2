class CreateWelcomeProject < ApplicationService
  attr_reader :account_id

  def initialize(account_id)
    @account = Account.find(account_id)
  end

  def call
    user_id = @account.users.first.id

    ActiveRecord::Base.transaction do
      # Création de la table
      table = @account.tables.create(name: "Consommation")
      field1 = table.fields.create(name: "Café", datatype: "nombre")
      field2 = table.fields.create(name: "Pizza", datatype: "nombre")
      field3 = table.fields.create(name: "Kinder Bueno", datatype: "nombre")
      field4 = table.fields.create(name: "Coca Cola", datatype: "nombre")
      field5 = table.fields.create(name: "Humeur", datatype: "liste", items: "Extra, Bonne, Neutre, Mauvaise, Exécrable")

      # Création du projet
      project = @account.projects.create(name: "Découvrir Camino", description: "Projet de bienvenue", table_id: table.id, duedate: Date.today + 7.days)
      project.participants.create(user_id: user_id)

      # Ajout de todolists
      todolist1 = project.todolists.create(name: "Découvrir le b.a.-ba (Béaba)")
      todolist2 = project.todolists.create(name: "Créer un projet avec Camino")
      todolist3 = project.todolists.create(name: "Inviter un collègue", duedate: Date.today + 6.days)

      # Ajout de todos
      todolist1_todo_1 = todolist1.todos.create(name: "Parcourir les menus (To-do, Agenda, Activité, Discussions...)", user_id: user_id, done: false, duedate: Date.tomorrow)
      todolist1_todo_2 = todolist1.todos.create(name: "Ajouter une tâche dans cette todolist", user_id: user_id, done: false)

      todolist2_todo_1 = todolist2.todos.create(name: "Découper le projet en liste (Todolist)", user_id: user_id, done: false, duedate: Date.today + 3.days)
      todolist2_todo_2 = todolist2.todos.create(name: "Ajouter dans chaque todolist les tâches à faire", user_id: user_id, done: false)

      todolist3_todo_1 = todolist3.todos.create(name: "Créer un utilisateur(participant)", user_id: user_id, done: false)
      todolist3_todo_1.comments.create(user_id: user_id, texte: "Pour créer un participant, il faut aller sur l'onglet 'Projets', et cliquer sur le bouton (+) à côté de votre avatar")
      todolist3_todo_2 = todolist3.todos.create(name: "Ajouter le nouvel utilisateur au projet", user_id: user_id, done: false)

      # Ajout de données dans la table
      todolist2_todo_1.values.create(data: '4', field_id: field1.id, record_index: 1, user_id: user_id, table_id: table.id)
      todolist2_todo_1.values.create(data: '1', field_id: field2.id, record_index: 1, user_id: user_id, table_id: table.id)
      todolist2_todo_1.values.create(data: '2', field_id: field3.id, record_index: 1, user_id: user_id, table_id: table.id)
      todolist2_todo_1.values.create(data: '2', field_id: field4.id, record_index: 1, user_id: user_id, table_id: table.id)
      todolist2_todo_1.values.create(data: 'Extra', field_id: field5.id, record_index: 1, user_id: user_id, table_id: table.id)

      todolist3_todo_2.values.create(data: '1', field_id: field1.id, record_index: 2, user_id: user_id, table_id: table.id)
      todolist3_todo_2.values.create(data: '0', field_id: field2.id, record_index: 2, user_id: user_id, table_id: table.id)
      todolist3_todo_2.values.create(data: '1', field_id: field3.id, record_index: 2, user_id: user_id, table_id: table.id)
      todolist3_todo_2.values.create(data: '0', field_id: field4.id, record_index: 2, user_id: user_id, table_id: table.id)
      todolist3_todo_2.values.create(data: 'Bonne', field_id: field5.id, record_index: 2, user_id: user_id, table_id: table.id)

      table.update(record_index: 2)
    end
  end
end