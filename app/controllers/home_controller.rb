class HomeController < ApplicationController
  def index
  end

  def search
    @query = params[:q].strip
    
    unless @query.present? && @query.include?('#')
      flash.now[:alert] = "Formato inválido. Use: Nome#Tag"
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
      Rails.logger.info("Searching for LOL profile: #{game_name}##{tag_line}")
      
      # Busca conta na API da Riot
      account_data = RiotApi::AccountService.get_account_by_riot_id(game_name, tag_line)
      Rails.logger.info("Account Data: #{account_data.inspect}")
      
      # Busca dados do summoner
      summoner_data = RiotApi::SummonerService.get_summoner_by_puuid(account_data[:puuid])
      Rails.logger.info("Summoner Data: #{summoner_data.inspect}")
      
      # Busca dados de ranked
      @ranked_data = RiotApi::LeagueService.get_ranked_data(account_data[:puuid])
      Rails.logger.info("Ranked Data: #{@ranked_data.inspect}")
      
      @player_info = {
        game_name: account_data[:game_name],
        tag_line: account_data[:tag_line],
        puuid: account_data[:puuid],
        profile_icon_id: summoner_data[:profile_icon_id],
        summoner_level: summoner_data[:summoner_level]
      }

      render :profile_result
    rescue StandardError => e
      Rails.logger.error("Error searching for LOL profile: #{e.class} - #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      flash.now[:alert] = "Erro ao buscar perfil: #{e.message}"
      render :index
    end
  end
end