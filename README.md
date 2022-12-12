# Camino

# Gérer, en équipe, vos petits projets

* Découpez vos projets en listes de choses à faire
* Invitez vos contacts à participer
* Assignez aux participants certaines choses à faire
* Fixez les échéances
* Suivez l'activité des participants (commentaires, travaux terminés, etc.)

# Fonctionnalités

    * Création rapide de nouveaux projets à partir de modèles
    * Le journal recense, minute par minute, l'actitivé des participants
    * Un agenda permet de visualiser les échéances
    * Déroulement de projet au choix:
        ** Libre; les tâches peuvent être terminées librement, dans n'importe quel ordre
        ** Linéaire; toutes les tâches d'une liste doivent être terminées avant de pouvoir passer à la liste suivante.
        Quand une tâche est terminée, le participant assigné à la tâche suivante en est immédiatement informé
    * Un courriel de notification est envoyé aux participants:
        ** Après chaque modification, ajout ou suppression d'information
        ** Lors de l'assignation d'une tâche à un participant
        ** Avant chaque échéance de tâche ou de projet
    * Les participants peuvent mener une discussion autour de choses à faire, attacher des documents
    * Taggez vos projets pour les regrouper par mots clés
    * Assignez une couleur à chaque projet
    * Notifiez automatiquement votre client dès la réalisation d'une tâche

# Installation

CaminoV2 est une application <a href="http://rubyonrails.org/">Ruby On Rails 7</a>. 

Pour pouvoir executer l'application vous devez installer d'abord Ruby On Rails 7 sur votre serveur Linux en suivant ce tutoriel :<a href="https://gorails.com/setup/ubuntu/22.04">gorails.com/setup/ubuntu</a>.
Ensuite, pour copier les sources à partir de ce répertoire et lancer l'application en utilisant le processus classique, lancer les commandes suivantes :

* git clone https://github.com/philippe-nougaillon/Camino2.git
* cd Camino2
* bundle install
* rails db:setup
* rails s