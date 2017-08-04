class RaidSpawn < ApplicationRecord
  belongs_to :pokemon, foreign_key: 'pokedex_number'
  validates_presence_of   :pokedex_number, :longitude, :latitude, :expires_at
  validates_uniqueness_of :pokedex_number, scope: [:longitude, :latitude, :expires_at]

  reverse_geocoded_by :latitude, :longitude

  def pokemon_name
    self.pokemon.name
  end

  def to_coordinates
    [latitude, longitude]
  end

  def ll_string
    to_coordinates.join(',')
  end
end
