class AddLevelAndStreetToRaidSpawns < ActiveRecord::Migration[5.0]
  def change
    add_column :raid_spawns, :level, :integer
    add_column :raid_spawns, :street, :string
  end
end
