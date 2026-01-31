# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Create user with LOL profile
user = User.find_or_create_by!(email: 'isinha@tournament.local') do |u|
  u.username = 'isinha_player'
  u.password = 'SecurePassword123!'
  u.password_confirmation = 'SecurePassword123!'
  u.role = :player
  u.confirmed_at = Time.current
end

# Create or update LOL profile
account_data = RiotApi::AccountService.get_account_by_riot_id('isinha', '0302')

user.create_lol_profile!(
  puuid: account_data[:puuid],
  game_name: account_data[:game_name],
  tag_line: account_data[:tag_line]
) unless user.lol_profile.present?

puts "✅ Usuário criado: #{user.username} (#{user.email})"
puts "✅ Perfil LOL: #{user.lol_profile.game_name}##{user.lol_profile.tag_line}"
puts "✅ PUUID: #{user.lol_profile.puuid}"