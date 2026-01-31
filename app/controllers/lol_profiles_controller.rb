# frozen_string_literal: true

class LolProfilesController < ApplicationController
  before_action :authenticate_user!, only: [:link]

  def link
    @lol_profile = LolProfile.find(params[:id])

    if current_user.lol_profile.present?
      redirect_to profile_path, alert: "Você já possui um perfil LOL vinculado"
      return
    end

    if @lol_profile.user.present?
      redirect_to profile_path, alert: "Este perfil LOL já está vinculado com outra conta"
      return
    end

    if current_user.update(lol_profile: @lol_profile)
      redirect_to profile_path, notice: "Perfil LOL vinculado com sucesso!"
    else
      redirect_to profile_path, alert: "Erro ao vincular perfil LOL"
    end
  end
end
