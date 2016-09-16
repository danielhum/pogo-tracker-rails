class UpdateSpawns
  include Sidekiq::Worker

  KEY_INSERTED = 'update_spawns:inserted_meta'

  def perform(since: nil, split_requests: true, save_spawns: true)
    nums = [
      1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,116,117,118,119,120,121,123,124,125,126,127,129,130,131,133,134,135,136,137,138,139,140,141,142,143,147,148,149
    ]
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
    if split_requests
      shuffled = nums.shuffle
      idx = 65+rand(10)
      slices = shuffled[0,idx], shuffled[idx..-1]
    else
      slices = [nums]
    end
    all_spawns = []
    slices.each_with_index do |mons,i|
      mons = mons.sort
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
          spawn = PokemonSpawn.new(pokedex_number: pk['pokemon_id'].to_i,
                                   latitude: pk['lat'].to_f,
                                   longitude: pk['lng'].to_f,
                                   expires_at: pk['despawn'].to_i)
          spawn.save if save_spawns
          all_spawns << spawn
        }
      end

      if save_spawns and i == 0 and meta = json['meta']
        inserted = meta['inserted']
        puts "inserted: #{inserted}"
        $redis.set KEY_INSERTED, inserted if !inserted.blank?
      end

      sleep(10+rand(15)) if slices.count-1 > i
    end

    return all_spawns
  end

end
