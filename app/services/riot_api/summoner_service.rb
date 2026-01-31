# app/services/riot_api/summoner_service.rb
module RiotApi
  class SummonerService
    BASE_URL = ENV.fetch('RIOT_API_BASE_URL_LEAGUE', 'https://br1.api.riotgames.com')
    API_KEY = ENV.fetch('RIOT_API_KEY')
    DDRAGON_VERSION = ENV.fetch('DDRAGON_VERSION', '16.2.1')

    def self.get_summoner_by_puuid(puuid)
      new.get_summoner_by_puuid(puuid)
    end

    def get_summoner_by_puuid(puuid)
      url = "#{BASE_URL}/lol/summoner/v4/summoners/by-puuid/#{puuid}"
      
      response = fetch(url)
      
      {
        profile_icon_id: response['profileIconId'],
        summoner_level: response['summonerLevel'],
        revision_date: response['revisionDate']
      }
    rescue StandardError => e
      raise "Erro ao buscar dados do summoner: #{e.message}"
    end

    def self.get_profile_icon_url(icon_id)
      "https://ddragon.leagueoflegends.com/cdn/#{DDRAGON_VERSION}/img/profileicon/#{icon_id}.png"
    end

    private

    def fetch(url)
      uri = URI(url)
      uri.query = URI.encode_www_form({ api_key: API_KEY })

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri)
      response = http.request(request)

      case response.code.to_i
      when 200
        JSON.parse(response.body)
      when 404
        raise "Summoner não encontrado"
      when 403
        raise "Chave da API inválida"
      when 429
        raise "Limite de requisições atingido"
      else
        raise "Erro na requisição: #{response.code} - #{response.body}"
      end
    end
  end
end