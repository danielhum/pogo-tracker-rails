# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170804025101) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "pokemon_spawns", force: :cascade do |t|
    t.integer  "pokedex_number"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "expires_at"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["expires_at"], name: "index_pokemon_spawns_on_expires_at", order: {"expires_at"=>:desc}, using: :btree
    t.index ["latitude", "longitude"], name: "index_pokemon_spawns_on_latitude_and_longitude", using: :btree
  end

  create_table "pokemons", force: :cascade do |t|
    t.string   "name"
    t.integer  "pokedex_number"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["pokedex_number"], name: "index_pokemons_on_pokedex_number", using: :btree
  end

  create_table "raid_spawns", force: :cascade do |t|
    t.integer  "pokedex_number"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "expires_at"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "level"
    t.string   "street"
  end

end
