class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable

  # Associations
  has_one :lol_profile, dependent: :destroy

  # Enums
  enum :role, {
    player: 0,
    organizer: 1
  }

  # Validations
  validates :username, 
    presence: true,
    uniqueness: { case_sensitive: false },
    length: { minimum: 3, maximum: 20 },
    format: { with: /\A[a-zA-Z0-9_]+\z/, message: "apenas letras, números e underscore" }

  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :summoner_name,
    uniqueness: { case_sensitive: false, allow_blank: true }

  # Callbacks
  before_validation :set_default_role, on: :create
  before_save :downcase_username
  before_save :downcase_summoner_name

  # Scopes
  scope :players, -> { where(role: :player) }
  scope :organizers, -> { where(role: :organizer) }

  def organizer?
    role == 'organizer'
  end

  def player?
    role == 'player'
  end

  def display_name
    username.presence || email.split('@').first
  end

  def avatar_initials
    username[0..1].upcase
  end

  private

  def set_default_role
    self.role ||= :player
  end

  def downcase_username
    self.username = username.downcase if username.present?
  end

  def downcase_summoner_name
    self.summoner_name = summoner_name.downcase if summoner_name.present?
  end
end