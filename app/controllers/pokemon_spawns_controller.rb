class PokemonSpawnsController < ActionController::Metal
  include AbstractController::Rendering
  include ActionView::Rendering
  include ActionController::Rendering
  include ActionController::Renderers

  use_renderers :json

  def index
    ll = params[:ll]
    if ll
      spawns = PokemonSpawn.near(ll, 1.0, units: :km).
        where("expires_at > ?", Time.now.to_i).
        includes(:pokemon)
      render json: spawns
    else
      head :bad_request
    end
  end

end
