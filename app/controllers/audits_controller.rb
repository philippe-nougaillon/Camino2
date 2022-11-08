class AuditsController < ApplicationController
  def index
    @audits  = Audited::Audit.order('id DESC')
    @actions = @audits.pluck(:action).uniq.sort
    @types   = @audits.pluck(:auditable_type).uniq.sort
    @users   = User.all

    @audits = @audits.where('DATE(created_at) = ?', params[:date]) unless params[:date].blank?

    @audits = @audits.where(action: params[:audit_action]) unless params[:audit_action].blank?

    @audits = @audits.where(auditable_type: params[:type]) unless params[:type].blank?

    return if params[:user_id].blank?

    @audits = @audits.where(user_id: params[:user_id])
  end
end
