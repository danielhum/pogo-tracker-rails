require 'slack-notifier'

class NotifySlack
  include Sidekiq::Worker

  NOTIFIER = Slack::Notifier.new(ENV['SLACK_WEBHOOK_URL'],
                                  channel: '#bot-dev',
                                  username: 'pogo-tracker')

  def perform(spawns={})
    spawns = spawns.symbolize_keys
    pokemon_spawns = spawns[:pokemon_spawns] # PokemonSpawn IDs
    raid_spawns    = spawns[:raid_spawns]    # RaidSpawn IDs

    puts "Notifying Slack -> #{spawns.inspect}"

    if raid_spawns.present?
      spawns = RaidSpawn.where(id: raid_spawns).includes(:pokemon)
      spawns.each do |spawn|
        if Geocoder::Calculations.distance_between([1.309658,103.865530], spawn, units: :km).to_f < 2.0
          title = "New Raid! #{spawn.pokemon_name}"
          text  = [spawn.latitude, spawn.longitude].join(',')
          attachment = {
            fallback: "#{title} @ #{text}",
            title: title,
            title_link: "https://www.google.com/maps/search/?api=1&query=#{text}",
            text: text,
            image_url: "https://maps.googleapis.com/maps/api/staticmap?key=#{ENV['GOOGLE_MAPS_API_KEY']}&size=400x300&zoom=17&markers=#{spawn.ll_string}",
            color: 'good'
          }
          puts text
          NOTIFIER.ping "", icon_emoji: ":pokeball:", attachments: [attachment]
        else
          puts "#{spawn.id} not within 1km"
        end
      end
    end

  end
end
