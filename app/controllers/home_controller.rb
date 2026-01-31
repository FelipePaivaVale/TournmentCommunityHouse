class HomeController < ApplicationController
  def index
  end

  def search
    @query = params[:q].strip
    
    unless @query.present? && @query.include?('#')
      flash.now[:alert] = "Formato inválido. Use: Nome#Tag (ex: isinha#0302)"
      render :index
      return
    end

    game_name, tag_line = @query.split('#', 2)
    game_name = game_name.strip
    tag_line = tag_line.strip

    if game_name.blank? || tag_line.blank?
      flash.now[:alert] = "Nome e tag não podem estar vazios. Use: Nome#Tag"
      render :index
      return
    end

    begin
      account_data = RiotApi::AccountService.get_account_by_riot_id(game_name, tag_line)
      
      @lol_profile = LolProfile.find_or_create_by!(
        puuid: account_data[:puuid]
      ) do |profile|
        profile.game_name = account_data[:game_name]
        profile.tag_line = account_data[:tag_line]
      end

      render :profile_result
    rescue StandardError => e
      flash.now[:alert] = e.message
      render :index
    end
  end
end