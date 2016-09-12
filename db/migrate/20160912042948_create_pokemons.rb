class CreatePokemons < ActiveRecord::Migration[5.0]
  def change
    create_table :pokemons do |t|
      t.string :name
      t.integer :pokedex_number

      t.timestamps
    end

    add_index :pokemons, :pokedex_number, unique: true
  end
end
