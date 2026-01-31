class DashboardController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @user = current_user
    
    # Estatísticas do usuário
    @user_stats = {
      matches_played: current_user.player&.matches&.count || 0,
      win_rate: calculate_win_rate
    }
    
    # Próximas partidas
    @upcoming_matches = current_user.player&.matches&.upcoming || []
    
    # Times do usuário
    @user_teams = current_user.teams.limit(5)
    
    # Conquistas
    @achievements = fetch_achievements
  end
  
  private
  
  def calculate_win_rate
    matches = current_user.player&.matches || []
    return 0 if matches.empty?
    
    wins = matches.where(status: :completed).select { |m| m.winner_id == current_user.player&.team_id }
    ((wins.count.to_f / matches.count) * 100).round(1)
  end
  
  def fetch_achievements
    [
      { name: 'Primeiro Torneio', icon: 'trophy', unlocked: current_user.participations.any?, progress: 100 },
      { name: 'Vencedor', icon: 'crown', unlocked: current_user.participations.where(position: 1).any?, progress: current_user.participations.where(position: 1).any? ? 100 : 25 },
      { name: 'Participante Ativo', icon: 'user-check', unlocked: current_user.participations.count >= 5, progress: [(current_user.participations.count * 20), 100].min },
      { name: 'Lenda da Summoner\'s Rift', icon: 'fire', unlocked: false, progress: 10 }
    ]
  end
end