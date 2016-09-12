class Pokemon < ApplicationRecord
  self.primary_key = 'pokedex_number'
  validates :pokedex_number, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
  has_many :spawns, class_name: 'PokemonSpawn', foreign_key: 'pokedex_number'
end
