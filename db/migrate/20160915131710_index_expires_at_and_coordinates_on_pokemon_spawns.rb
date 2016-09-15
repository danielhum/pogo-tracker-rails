class IndexExpiresAtAndCoordinatesOnPokemonSpawns < ActiveRecord::Migration[5.0]
  def change
    add_index :pokemon_spawns, [:latitude, :longitude]
  end
end
