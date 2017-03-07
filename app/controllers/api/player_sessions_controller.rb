class Api::PlayerSessionsController < ApiController
  before_filter :find_or_initialize_player_session, except: [:index]

  def index
    render json: current_api_user.player_sessions.order(finished_at: :desc), status: 200, each_serializer: PlayerSessionSerializer
  end

  def show
    if @player_session.persisted?
      render json: @player_session, status: 200, serializer: PlayerSessionSerializer
    else
      render json: {message: "Player Session not found"}, status: 404
    end
  end

  def destroy
    if @player_session.persisted?
      @player_session.destroy
      render json: {message: "Player Session deleted"}, status: 200
    else
      render json: {message: "Player Session not found"}, status: 404
    end
  end

  def create
    update
  end

  def update
    if @player_session.update_attributes(player_session_params)
      render json: @player_session, status: 200, serializer: PlayerSessionSerializer
    else
      render json: {message: "Invalid Player Session."}, :status => :unprocessable_entity #422
    end
  end

  private

  def find_or_initialize_player_session
    @player_session ||= PlayerSession.find_or_initialize_by(id:params[:id])
    if @player_session.persisted? && @player_session.user_id != current_api_user.id
      return not_authenticated
    else
      @player_session.user_id = current_api_user.id
    end
  end

  def player_session_params
    begin
      params.require(:player_session).permit(:started_at, :finished_at)
    rescue ActionController::ParameterMissing => e
      {}
    end
  end

end
