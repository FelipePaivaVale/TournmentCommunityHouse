class Admins::RegistrationsController < Devise::RegistrationsController
  layout 'admin'
  
  before_action :authenticate_admin!, only: [:new, :create]
  before_action :check_super_admin, only: [:new, :create, :destroy]

  # GET /resource/sign_up
  def new
    super
  end

  # POST /resource
  def create
    super do |resource|
      if resource.persisted?
        # Lógica adicional após criar admin
        Rails.logger.info "Admin criado: #{resource.email}"
      end
    end
  end

  private

  def check_super_admin
    unless current_admin&.super_admin?
      redirect_to admin_dashboard_path, alert: "Apenas super administradores podem gerenciar outros administradores."
    end
  end
end