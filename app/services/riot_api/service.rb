module RiotApi
  class Service
    BASE_URL = ENV['RIOT_API_BASE_URL'] || 'https://americas.api.riotgames.com'
    REGION = ENV['RIOT_API_REGION'] || 'br1'
    
    def initialize
      @api_key = ENV['RIOT_API_KEY']
      @conn = Faraday.new(url: BASE_URL) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
        faraday.headers['X-Riot-Token'] = @api_key
      end
    end
    
    def get_summoner_by_name(name)
      response = @conn.get("/lol/summoner/v4/summoners/by-name/#{URI.encode_www_form_component(name)}")
      handle_response(response)
    end
    
    def get_match_history(puuid, count: 20)
      response = @conn.get("/lol/match/v5/matches/by-puuid/#{puuid}/ids", { count: count })
      handle_response(response)
    end
    
    def get_match_details(match_id)
      response = @conn.get("/lol/match/v5/matches/#{match_id}")
      handle_response(response)
    end
    
    def get_league_entries(summoner_id)
      response = @conn.get("/lol/league/v4/entries/by-summoner/#{summoner_id}")
      handle_response(response)
    end
    
    private
    
    def handle_response(response)
      case response.status
      when 200
        JSON.parse(response.body)
      when 404
        raise RiotApi::NotFoundError, "Recurso não encontrado"
      when 403
        raise RiotApi::ForbiddenError, "API key inválida ou expirada"
      when 429
        raise RiotApi::RateLimitError, "Limite de requisições excedido"
      else
        raise RiotApi::Error, "Erro na API: #{response.status}"
      end
    end
  end
  
  class Error < StandardError; end
  class NotFoundError < Error; end
  class ForbiddenError < Error; end
  class RateLimitError < Error; end
end