class Admin < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :lockable

  # Validations
  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :name,
    presence: true,
    length: { minimum: 2, maximum: 50 }


  def display_name
    name.presence || email.split('@').first
  end

  private

end