class ApiController < ActionController::Base

  before_filter :require_auth_token, :except => [:not_authenticated]

  def current_api_user
    @current_api_user ||= User.find_by_auth_token(params[:auth_token])
  end

  protected

  def require_auth_token
    not_authenticated unless current_api_user
  end

  def not_authenticated
    render json: { message: "Invalid authorization token" }, :status => 401
    false
  end
end
