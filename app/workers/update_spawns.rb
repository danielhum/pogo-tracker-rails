class UpdateSpawns
  include Sidekiq::Worker

  KEY_INSERTED = 'update_spawns:inserted_meta'

  def perform(since: nil)
    nums  = Pokemon.pluck(:pokedex_number)
    nums -= [
      144, # Articuno
      145, # Zapdos
      146, # Moltres
      150, # Mewtwo
      151, # Mew
      132, # Ditto
      115, # Kangaskhan
      128, # Tauros
      122, # Mr Mime
      83,  # Farfetch'd
    ]
    since = $redis.get(KEY_INSERTED) || 0 if since.nil?
    nums.each_slice(44) do |mons|
      r = HTTParty.get(ENV['UPDATE_SPAWNS_ENDPOINT'] + "?since=#{since}&mons=" \
                       + mons.join(','))
      json = JSON.load(r.body)

      pokemons = json['pokemons']
      if pokemons
        pokemons.each{ |pk|
          PokemonSpawn.create(pokedex_number: pk['pokemon_id'].to_i,
                              latitude: pk['lat'].to_f,
                              longitude: pk['lng'].to_f,
                              expires_at: pk['despawn'].to_i)
        }
      end

      if meta = json['meta']
        inserted = meta['inserted']
        $redis.set KEY_INSERTED, inserted if !inserted.blank?
      end
    end

  end

end
