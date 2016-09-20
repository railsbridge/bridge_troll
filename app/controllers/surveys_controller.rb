class SurveysController < ApplicationController
  before_action :authenticate_user!
  before_action :find_event
  before_action :find_rsvp, except: [:index, :preview]

  def new
    authorize @rsvp, :survey?
    @survey = Survey.where(rsvp_id: @rsvp.id).first_or_initialize

    if @survey.persisted?
      flash[:error] = "It looks like you've already taken this survey! Email your workshop organizer with any other feedback you have."
    end
  end

  def create
    authorize @rsvp, :survey?
    @survey = Survey.new(survey_params)
    @survey.rsvp_id = @rsvp.id

    if @survey.save
      flash[:notice] = "Thanks for taking the survey!"
      redirect_to root_path
    else
      render :new
    end
  end

  def index
    authorize @event, :edit?
    @student_surveys = Survey.where(rsvp_id: @event.rsvps.where(role_id: Role::STUDENT.id).pluck(:id))
    @volunteer_surveys = Survey.where(rsvp_id: @event.volunteer_rsvps.pluck(:id))
  end

  def preview
    authorize @event, :edit?
    @survey = Survey.new
    @rsvp = Rsvp.new(id: 0)
    @preview = true
    render :new
  end

  private

  def survey_params
    params.require(:survey).permit(Survey::PERMITTED_ATTRIBUTES)
  end

  def find_event
    @event = Event.find(params[:event_id])
  end

  def find_rsvp
    @rsvp = current_user.rsvps.find_by!(event_id: @event.id)
  end
end
