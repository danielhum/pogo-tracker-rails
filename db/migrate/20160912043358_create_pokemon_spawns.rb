class CreatePokemonSpawns < ActiveRecord::Migration[5.0]
  def change
    create_table :pokemon_spawns do |t|
      t.integer :pokedex_number
      t.float :latitude, default: 0
      t.float :longitude, default: 0
      t.integer :expires_at, default: 0

      t.timestamps
    end

    add_index :pokemon_spawns, :expires_at, order: { expires_at: "DESC NULLS LAST" }
  end
end
