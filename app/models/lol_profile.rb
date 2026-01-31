# frozen_string_literal: true

class LolProfile < ApplicationRecord
  belongs_to :user, optional: true

  validates :puuid, presence: true, uniqueness: true
  validates :game_name, presence: true
  validates :tag_line, presence: true
end
