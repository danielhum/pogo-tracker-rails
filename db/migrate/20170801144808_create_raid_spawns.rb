class CreateRaidSpawns < ActiveRecord::Migration[5.0]
  def change
    create_table :raid_spawns do |t|
      t.integer :pokedex_number
      t.float :latitude
      t.float :longitude
      t.integer :expires_at

      t.timestamps
    end
  end
end
