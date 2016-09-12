namespace :pokemons do
  task :generate => :environment do
    Pokemon.destroy_all
    file = File.read('pokemons.json')
    JSON.parse(file).each do |p|
      Pokemon.create(p)
    end
  end
end
