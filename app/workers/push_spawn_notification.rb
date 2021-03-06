class PushSpawnNotification
  include Sidekiq::Worker

  FCM_SERVER_KEY = ENV['FCM_SERVER_KEY']
  FCM_BASE_URL   = "https://fcm.googleapis.com/fcm/send"

  def perform(pokemon_spawn_ids)
    if FCM_SERVER_KEY.blank?
      Rails.logger.error "PushSpawnNotification FCM_SERVER_KEY blank!"
      return
    end

    pokemon_spawn_ids = [pokemon_spawn_ids].flatten
    spawns = PokemonSpawn.where(id: pokemon_spawn_ids).includes(:pokemon)

    spawns.each do |spawn|
      Rails.logger.info "Pushing Notification for [#{spawn.pokedex_number}]#{spawn.pokemon_name}"
    end
    spawns.each_slice(5) do |push_spawns|
      HTTParty.post(FCM_BASE_URL, headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "key=#{FCM_SERVER_KEY}"
      }, body: {
        data: {
          pokemon_spawns: push_spawns.as_json(except: [:created_at, :updated_at])
        },
        to: '/topics/pokemon_spawns'
      }.to_json)
    end
  end
end
