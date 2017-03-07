class Api::UserSessionsController < ApiController
  skip_before_filter :require_auth_token, :only => [:create]

  def create
    user = User.find_by_email(params[:email])
    if user.blank? || !user.valid_password?(params[:password])
      render json: { message: "Invalid credentials" }, status: :unauthorized
    elsif user.registration_pending?
      render json: { message: "Registration pending" }, status: 412
    else
      render json: user, serializer: UserWithTokenSerializer
    end
  end

  def reset
    current_api_user.reset_auth_token!
    render json: { message: "Auth token reset successful" }, status: 200
  end

end
