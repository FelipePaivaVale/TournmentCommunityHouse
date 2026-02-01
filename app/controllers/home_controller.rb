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
      
      # Busca histórico de partidas
      @match_ids = RiotApi::MatchService.get_match_ids(account_data[:puuid], 10)
      Rails.logger.info("Match IDs: #{@match_ids.inspect}")
      
      # Busca detalhes das primeiras 10 partidas
      @matches = []
      @match_ids.first(10).each do |match_id|
        match = RiotApi::MatchService.get_match_details(match_id, account_data[:puuid])
        @matches << match if match
      end
      
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
  
  def load_more_matches
    begin
      puuid = params[:puuid]
      offset = params[:offset].to_i || 0
      
      # Busca mais IDs de partidas
      match_ids = RiotApi::MatchService.get_match_ids(puuid, 10, offset)
      
      # Busca detalhes das partidas
      @matches = []
      match_ids.each do |match_id|
        match = RiotApi::MatchService.get_match_details(match_id, puuid)
        @matches << match if match
      end
      
      render partial: 'matches_list', locals: { matches: @matches }
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end
end