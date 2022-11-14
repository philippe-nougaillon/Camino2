class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  # before_action :detect_device_format
  before_action :set_layout_variables


  private

  def set_layout_variables
    @sitename ||= 'Camino'
    @sitename.concat(' v2.2')
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
      # when /Android/i
      #  request.variant = :tablet
      # when /iPad/i
      #  request.variant = :tablet
    end
  end

  def after_sign_in_path_for(_resource)
    projects_path
  end
end
