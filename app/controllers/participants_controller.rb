class ParticipantsController < ApplicationController
  before_action :set_participant, only: %i[ edit update ]
  before_action :user_authorized?

  # GET /participants/1/edit
  def edit; end

  # PATCH/PUT /participants/1
  # PATCH/PUT /participants/1.json
  def update
    respond_to do |format|
      if @participant.update(participant_params)
        format.html { redirect_to @participant.user, notice: 'Modification enregistrée...' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @participant.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_participant
    @participant = Participant.find_by(slug: params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def participant_params
    params.require(:participant).permit(:project_id, :user_id, :want_notification, :want_dailynewsletter,
                                        :want_weeklynewsletter, :client)
  end

  def user_authorized?
    authorize @participant
  end
end
