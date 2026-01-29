class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    super
  end

  # POST /resource
  def create
    super do |resource|
      # Lógica adicional após criar usuário
      if resource.persisted?
        # Aqui você pode adicionar lógica adicional
        # Ex: Criar perfil de jogador, enviar email, etc.
        Rails.logger.info "Usuário criado: #{resource.email}"
      end
    end
  end

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  def destroy
    super
  end
  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :username, 
      :summoner_name,
      :email,
      :password,
      :password_confirmation
    ])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :username,
      :summoner_name,
      :email,
      :password,
      :password_confirmation,
      :current_password
    ])
  end

  def after_sign_up_path_for(resource)
    # Após cadastro, redireciona para página de confirmação
    if resource.active_for_authentication?
      root_path
    else
      new_user_session_path
    end
  end

  def after_update_path_for(resource)
    profile_path
  end
end