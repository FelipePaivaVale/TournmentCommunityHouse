class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  def after_sign_in_path_for(resource)
    # Redireciona baseado no tipo de usuário
    if resource.admin?
      admin_dashboard_path
    elsif resource.organizer?
      tournaments_path
    else
      root_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end