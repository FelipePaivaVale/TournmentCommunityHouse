class AdminController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!
  before_action :set_admin_nav
  
  private
  
  def set_admin_nav
    @admin_nav = {
      dashboard: { path: admin_dashboard_path, icon: 'speedometer2', active: current_page?(admin_dashboard_path) },
      users: { path: admin_users_path, icon: 'people', active: controller_name == 'users' }
    }
  end
end