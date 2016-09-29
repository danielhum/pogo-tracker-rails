class PokemonSpawn < ApplicationRecord
  belongs_to :pokemon, foreign_key: 'pokedex_number'
  validates_presence_of   :pokedex_number, :longitude, :latitude, :expires_at
  validates_uniqueness_of :pokedex_number, scope: [:longitude, :latitude, :expires_at]

  reverse_geocoded_by :latitude, :longitude

  def pokemon_name
    self.pokemon.name
  end

  def pokemon_icon
    s = ENV['POKEMON_ICON_URL'].to_s
    s.gsub('{id}',pokedex_number.to_s.rjust(3,'0'))
  end

  def as_json(options = {})
    options[:methods] = [:pokemon_name, :pokemon_icon]
    super(options)
  end
end
