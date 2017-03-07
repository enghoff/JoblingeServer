class Api::GameDataController < ApiController
  before_filter :find_and_authorize_game_data

  def show
    render json: @game_data, status: 200, serializer: GameDataSerializer
  end

  def update
    if !game_data_params.key?("data")
      render json: {message: "Invalid Game Data."}, :status => :unprocessable_entity
    else
      @game_data.update_attributes!(game_data_params)
      render json: {message: "Game Data saved."}
    end
  end

  private

  def find_and_authorize_game_data
    user = User.find_by_id(params[:user_id])
    return not_authenticated unless current_api_user == user
    @game_data = user.game_data
  end

  def game_data_params
    begin
      params.require(:game_data).permit!.slice(:data)
    rescue ActionController::ParameterMissing => e
      {}
    end
  end

end
