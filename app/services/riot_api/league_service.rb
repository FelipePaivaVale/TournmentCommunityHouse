module RiotApi
  class LeagueService
    BASE_URL = ENV.fetch('RIOT_API_BASE_URL_LEAGUE', 'https://br1.api.riotgames.com')
    API_KEY = ENV.fetch('RIOT_API_KEY')

    def self.get_ranked_data(puuid)
      new.get_ranked_data(puuid)
    end

    def get_ranked_data(puuid)
      url = "#{BASE_URL}/lol/league/v4/entries/by-puuid/#{puuid}"
      
      response = fetch(url)
      
      solo_queue = response.find { |data| data['queueType'] == 'RANKED_SOLO_5x5' }
      flex_queue = response.find { |data| data['queueType'] == 'RANKED_FLEX_SR' }
      
      {
        solo: solo_queue ? format_queue_data(solo_queue) : nil,
        flex: flex_queue ? format_queue_data(flex_queue) : nil
      }
    rescue StandardError => e
      raise "Erro ao buscar dados de ranked: #{e.message}"
    end

    private

    def format_queue_data(data)
      {
        queue_type: data['queueType'],
        tier: data['tier'],
        rank: data['rank'],
        league_points: data['leaguePoints'],
        wins: data['wins'],
        losses: data['losses'],
        winrate: calculate_winrate(data['wins'], data['losses']),
        veteran: data['veteran'],
        hot_streak: data['hotStreak'],
        fresh_blood: data['freshBlood']
      }
    end

    def calculate_winrate(wins, losses)
      total = wins + losses
      total > 0 ? ((wins.to_f / total) * 100).round(1) : 0
    end

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
        []
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