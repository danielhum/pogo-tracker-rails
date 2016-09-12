Rails.application.routes.draw do

  get '/spawns' => 'pokemon_spawns#index'

end
