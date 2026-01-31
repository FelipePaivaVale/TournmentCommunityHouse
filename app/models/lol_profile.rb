# frozen_string_literal: true

class LolProfile < ApplicationRecord
  belongs_to :user

  validates :puuid, presence: true, uniqueness: true
  validates :game_name, presence: true
  validates :tag_line, presence: true
  validates :user_id, uniqueness: true
end
