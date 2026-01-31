# frozen_string_literal: true

class CreateLolProfileService
  def initialize(user, game_name, tag_line)
    @user = user
    @game_name = game_name
    @tag_line = tag_line
  end

  def call
    account_data = RiotApi::AccountService.get_account_by_riot_id(@game_name, @tag_line)
    
    create_profile(account_data)
  end

  private

  def create_profile(account_data)
    profile = @user.build_lol_profile(
      puuid: account_data[:puuid],
      game_name: account_data[:game_name],
      tag_line: account_data[:tag_line]
    )

    raise "Erro ao criar perfil LOL: #{profile.errors.full_messages.join(', ')}" unless profile.save

    profile
  end
end
