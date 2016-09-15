class PokemonSpawnsController < ActionController::Metal
  include AbstractController::Rendering
  include ActionView::Rendering
  include ActionController::Rendering
  include ActionController::Renderers

  use_renderers :json

  def index
    ll = params[:ll]
    if ll.nil?
      head :bad_request
      return
    end

    range = 1.2 #km

    last_run = $redis.get UpdateSpawns::KEY_INSERTED
    if last_run.to_i < 5.minutes.ago.to_i
      spawns = UpdateSpawns.new.perform(since: 0,
                                        split_requests: false,
                                        save_spawns: false)
      box = Geocoder::Calculations.bounding_box(ll, range)
      # calculating distance between 2 points is slow, so filter first
      spawns.keep_if{ |sp|
        sp.latitude  >= box[0] && 
        sp.longitude >= box[1] && 
        sp.latitude  <= box[2] && 
        sp.longitude <= box[3]
      }
      spawns.keep_if{ |sp|
        Geocoder::Calculations.distance_between(
          [sp.latitude, sp.longitude], ll) <= range
      }
      ActiveRecord::Associations::Preloader.new.preload(spawns,:pokemon)
    else
      spawns = PokemonSpawn.near(ll, range).
        where("expires_at > ?", Time.now.to_i).
        includes(:pokemon)
    end

    render json: spawns

  end

end
