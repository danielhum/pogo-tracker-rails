class PokemonSpawnsController < ActionController::Metal
  include AbstractController::Rendering
  include ActionView::Rendering
  include ActionController::Rendering
  include ActionController::Renderers

  use_renderers :json

  def index
    ll = params[:ll]
    if ll
      spawns = PokemonSpawn.near(ll, 0.5, units: :km)
      render json: spawns
    else
      head :bad_request
    end
  end

end
