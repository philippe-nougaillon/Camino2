class AddSlugToParticipants < ActiveRecord::Migration[7.0]
  def change
    add_column :participants, :slug, :string
    add_index :participants, :slug, unique: true

    Participant.find_each(&:save)
  end
end
