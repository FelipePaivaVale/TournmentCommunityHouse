# frozen_string_literal: true

class CreateLolProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :lol_profiles, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true, index: { unique: true }
      
      # Riot API Response data
      t.string :puuid, null: false
      t.string :game_name, null: false
      t.string :tag_line, null: false
      
      # Indexed for quick lookups
      t.index [:puuid], unique: true
      t.index [:game_name, :tag_line], unique: true
      
      t.timestamps null: false
    end
  end
end
