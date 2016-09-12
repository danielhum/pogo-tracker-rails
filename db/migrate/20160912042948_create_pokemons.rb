class CreatePokemons < ActiveRecord::Migration[5.0]
  def change
    create_table :pokemons do |t|
      t.string :name
      t.integer :pokedex_number, index: true

      t.timestamps
    end
  end
end
