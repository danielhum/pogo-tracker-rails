class DeleteExpiredSpawns
  include Sidekiq::Worker

  def perform
    PokemonSpawn.where("expires_at <= ?", 1.hour.ago.to_i).delete_all
  end

end
