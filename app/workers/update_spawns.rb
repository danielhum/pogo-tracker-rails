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
    shuffled = nums.shuffle
    idx = 65+rand(10)
    slices = shuffled[0,idx], shuffled[idx..-1]
    slices do |mons|
      url = ENV['UPDATE_SPAWNS_ENDPOINT'] + "?since=#{since}&mons=#{mons.join(',')}"
      domain = ENV['UPDATE_SPAWNS_DOMAIN']
      puts url
      r = HTTParty.get(url, headers: {
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36",
        "referer" => "https://#{domain}/",
        "x-requested-with" => "XMLHttpRequest",
        "authority" => domain
      })
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
        puts "inserted: #{inserted}"
        $redis.set KEY_INSERTED, inserted if !inserted.blank?
      end

      sleep 10+rand(15)
    end

  end

end
