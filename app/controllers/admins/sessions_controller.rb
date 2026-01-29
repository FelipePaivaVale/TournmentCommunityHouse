class Admins::SessionsController < Devise::SessionsController
  layout 'admin'

  # before_action :configure_sign_in_params, only: [:create]

  protected

  def after_sign_in_path_for(resource)
    admin_dashboard_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_admin_session_path
  end
end