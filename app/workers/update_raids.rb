class UpdateRaids
  include Sidekiq::Worker

  def perform(since: nil, save_spawns: true)

    url = ENV['UPDATE_RAIDS_ENDPOINT']
    domain = ENV['UPDATE_RAIDS_DOMAIN']
    r = HTTParty.get(url, headers: {
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36",
        "referer" => "https://#{domain}/",
        "x-requested-with" => "XMLHttpRequest",
        "authority" => domain,
        "accept-language" => "en-US,en;q=0.8",
        "accept-encoding" => "gzip, deflate, sdch, br",
        "accept" => "*/*"
    })
    json = JSON.load(r.body)

    saved_spawn_ids = []
    raids = json['raids']
    if raids
      raids.each{ |pk|
        # reference:
        # {
        #   "id": "651160",
        #   "lat": "1.295355",
        #   "lng": "103.851709",
        #   "raid_spawn": "1501637588",
        #   "raid_start": "1501637589",
        #   "raid_end": "1501644789",
        #   "pokemon_id": "146",
        #   "level": "5",
        #   "cp": "41953",
        #   "team": "2",
        #   "move1": "269",
        #   "move2": "270"
        # }
        next unless pk['level'].to_i > 3
        pokedex_number = pk['pokemon_id'].to_i
        spawn = RaidSpawn.new(pokedex_number: pokedex_number,
                              latitude: pk['lat'].to_f,
                              longitude: pk['lng'].to_f,
                              expires_at: pk['raid_end'].to_i)
        saved_spawn_ids << spawn.id if spawn.save
      }
      NotifySlack.perform_async(raid_spawns: saved_spawn_ids)
    end

    return saved_spawn_ids
  end
end