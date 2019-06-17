class SettingsController < ApplicationController
  before_filter :has_admin_privileges
  def index
    @settings = Setting.all.first
  end
  
  def update
    Setting.first.update(params.require(:setting).permit(params[:setting].keys))
    redirect_to settings_path
  end
end
