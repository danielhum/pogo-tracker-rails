class PokemonSpawn < ApplicationRecord
  belongs_to :pokemon, foreign_key: 'pokedex_number'
  validates_presence_of :pokedex_number, :longitude, :latitude, :expires_at
end
