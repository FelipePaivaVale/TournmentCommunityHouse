module RiotApi
  class AccountService
    BASE_URL = ENV.fetch('RIOT_API_BASE_URL', 'https://americas.api.riotgames.com')
    API_KEY = ENV.fetch('RIOT_API_KEY')

    def self.get_account_by_riot_id(game_name, tag_line)
      new.get_account_by_riot_id(game_name, tag_line)
    end

    def get_account_by_riot_id(game_name, tag_line)
        encoded_game_name = game_name.gsub(' ', '%20')
        encoded_tag_line = tag_line.gsub(' ', '%20')
        Rails.logger.info("Fetching account for #{game_name}##{tag_line}")
        Rails.logger.info("Encoded URL components: #{encoded_game_name}, #{encoded_tag_line}")
        url = "#{BASE_URL}/riot/account/v1/accounts/by-riot-id/#{encoded_game_name}/#{encoded_tag_line}"
      
        response = fetch(url)
      
        {
            puuid: response['puuid'],
            game_name: response['gameName'],
            tag_line: response['tagLine']
        }
    rescue StandardError => e
        raise "Erro ao buscar conta na Riot API: #{e.message}"
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
        raise "Conta não encontrada na Riot"
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
