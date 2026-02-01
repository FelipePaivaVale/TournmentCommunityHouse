module RiotApi
  class MatchService
    BASE_URL = ENV.fetch('RIOT_API_BASE_URL_MATCH', 'https://americas.api.riotgames.com')
    API_KEY = ENV.fetch('RIOT_API_KEY')
    DDRAGON_VERSION = ENV.fetch('DDRAGON_VERSION', '16.2.1')

    def self.get_match_ids(puuid, count = 10, offset = 0)
      new.get_match_ids(puuid, count, offset)
    end

    def self.get_match_details(match_id, puuid)
      new.get_match_details(match_id, puuid)
    end

    def get_match_ids(puuid, count = 10, offset = 0)
      url = "#{BASE_URL}/lol/match/v5/matches/by-puuid/#{puuid}/ids"
      
      params = {
        start: offset,
        count: count
      }
      
      response = fetch(url, params)
      response || []
    rescue StandardError => e
      Rails.logger.error("Error fetching match IDs: #{e.message}")
      []
    end

    def get_match_details(match_id, puuid)
      url = "#{BASE_URL}/lol/match/v5/matches/#{match_id}"
      
      response = fetch(url)
      return nil unless response
      
      participant = response['info']['participants'].find { |p| p['puuid'] == puuid }
      return nil unless participant
      
      format_match_data(response, participant)
    rescue StandardError => e
      Rails.logger.error("Error fetching match details: #{e.message}")
      nil
    end

    def self.get_champion_image_url(champion_name)
      "https://ddragon.leagueoflegends.com/cdn/#{DDRAGON_VERSION}/img/champion/#{champion_name}.png"
    end

    def self.get_item_image_url(item_id)
      if item_id > 0
        "https://ddragon.leagueoflegends.com/cdn/#{DDRAGON_VERSION}/img/item/#{item_id}.png"
      else
        nil
      end
    end

    def self.get_spell_image_url(spell_id)
      "https://ddragon.leagueoflegends.com/cdn/#{DDRAGON_VERSION}/img/spell/#{get_spell_name_by_id(spell_id)}.png"
    end

    def self.get_rune_image_url(rune_id)
      "https://ddragon.leagueoflegends.com/cdn/img/#{rune_id}"
    end

    private

    def format_match_data(match_data, participant)
      {
        match_id: match_data['metadata']['matchId'],
        game_creation: Time.at(match_data['info']['gameCreation'] / 1000),
        game_duration: format_game_duration(match_data['info']['gameDuration']),
        game_mode: match_data['info']['gameMode'],
        queue_id: match_data['info']['queueId'],
        win: participant['win'],
        champion_id: participant['championId'],
        champion_name: participant['championName'],
        kills: participant['kills'],
        pentaKills: participant['pentaKills'],
        quadraKills: participant['quadraKills'],
        tripleKills: participant['tripleKills'],
        doubleKills: participant['doubleKills'],
        champion_level: participant['champLevel'],
        deaths: participant['deaths'],
        assists: participant['assists'],
        kda: calculate_kda(participant['kills'], participant['deaths'], participant['assists']),
        cs: participant['totalMinionsKilled'] + participant['neutralMinionsKilled'],
        cs_per_min: calculate_cs_per_min(
          participant['totalMinionsKilled'] + participant['neutralMinionsKilled'],
          match_data['info']['gameDuration']
        ),
        items: [
          participant['item0'],
          participant['item1'],
          participant['item2'],
          participant['item3'],
          participant['item4'],
          participant['item5'],
          participant['item6']
        ],
        summoner_spells: [
          participant['summoner1Id'],
          participant['summoner2Id']
        ],
        primary_rune: participant['perks']['styles'][0]['selections'][0]['perk'],
        secondary_rune_tree: participant['perks']['styles'][1]['style'],
        vision_score: participant['visionScore'],
        damage_dealt: participant['totalDamageDealtToChampions'],
        damage_taken: participant['totalDamageTaken'],
        gold_earned: participant['goldEarned'],
        lane: participant['lane'],
        role: participant['role']
      }
    end

    def format_game_duration(seconds)
      minutes = seconds / 60
      secs = seconds % 60
      "#{minutes}:#{secs.to_s.rjust(2, '0')}"
    end

    def calculate_kda(kills, deaths, assists)
      if deaths > 0
        ((kills + assists).to_f / deaths).round(2)
      else
        kills + assists
      end
    end

    def calculate_cs_per_min(cs, game_duration)
      minutes = game_duration / 60.0
      (cs / minutes).round(1)
    end

    def self.get_spell_name_by_id(spell_id)
      mapping = {
        1 => "SummonerBoost",
        3 => "SummonerExhaust",
        4 => "SummonerFlash",
        6 => "SummonerHaste",
        7 => "SummonerHeal",
        11 => "SummonerSmite",
        12 => "SummonerTeleport",
        13 => "SummonerMana",
        14 => "SummonerDot",
        21 => "SummonerBarrier",
        32 => "SummonerSnowball"
      }
      mapping[spell_id] || "SummonerFlash"
    end

    def fetch(url, params = {})
      max_retries = 3
      retry_count = 0

      begin
        uri = URI(url)
        params[:api_key] = API_KEY
        uri.query = URI.encode_www_form(params)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = 10

        request = Net::HTTP::Get.new(uri)
        response = http.request(request)

        case response.code.to_i
        when 200
          JSON.parse(response.body)
        when 404
          nil
        when 403
          raise "Chave da API inválida"
        when 429
          if retry_count < max_retries
            retry_count += 1
            sleep(1)
          else
            raise "Limite de requisições atingido após #{max_retries} tentativas"
          end
        else
          raise "Erro na requisição: #{response.code} - #{response.body}"
        end
      rescue StandardError => e
        raise e
      end
    end
  end
end