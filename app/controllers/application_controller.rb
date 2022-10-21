class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :detect_device_format
  before_action :set_layout_variables

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :username, :email, :password, :password_confirmation)}
  end

  private

  def set_layout_variables
    @sitename ||= "Camino"
    @sitename.concat(" v2.0") 
    @ctrl = params[:controller]
  end

  def detect_device_format
    case request.user_agent
    when /iPhone/i
      request.variant = :phone
    when /Android/i && /mobile/i
      request.variant = :phone
    when /Windows Phone/i
      request.variant = :phone
    #when /Android/i
    #  request.variant = :tablet
    #when /iPad/i
    #  request.variant = :tablet
    end
  end
end
