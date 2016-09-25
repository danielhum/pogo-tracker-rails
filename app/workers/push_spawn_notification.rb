class PushSpawnNotification
  include Sidekiq::Worker

  FCM_SERVER_KEY = ENV['FCM_SERVER_KEY']
  FCM_BASE_URL   = "https://fcm.googleapis.com/fcm/send"

  def perform(pokemon_spawn_id)
    if FCM_SERVER_KEY.blank?
      Rails.logger.error "PushSpawnNotification FCM_SERVER_KEY blank!"
      return
    end

    spawn = PokemonSpawn.find pokemon_spawn_id

    Rails.logger.info "Pushing Notification for [#{spawn.pokedex_number}]#{spawn.pokemon_name}"
    HTTParty.post(FCM_BASE_URL, headers: {
      'Content-Type' => 'application/json',
      'Authorization' => "key=#{FCM_SERVER_KEY}"
    }, body: {
      data: {
        pokemon_spawn: spawn.as_json
      },
      to: '/topics/pokemon_spawns'
    }.to_json)
  end
end
