class Api::UsersController < ApiController
  skip_before_filter :require_auth_token, :only => [:register]
  before_filter :find_and_authorize_user, :only => [:show, :change_password]

  def show
    render json: @user, status: 200, serializer: UserWithTokenSerializer
  end

  def register
    user = User.find_for_registration_code(params[:registration_code])
    if user.blank?
      render json: {message: "Invalid registration code"}, status: 401
    elsif user.registered?
      render json: { message: "User already registered. Use credentials to log in." }, status: 412
    else
      form = UserRegisterForm.new(register_params)
      form.record = user
      if form.valid?
        form.update_and_register
        render json: form.record, status: 200, serializer: UserWithTokenSerializer
      else
        render json: {errors: form.errors.messages}, :status => :unprocessable_entity #422
      end
    end
  end

  def change_password
    form = UserChangePasswordForm.new(password:params[:user][:password])
    form.record = @user
    if form.valid?
      form.save
      render json: {message: "Password changed"}, status: 200
    else
      render json: {errors: form.errors.messages}, :status => :unprocessable_entity #422
    end
  end

  private

  def find_and_authorize_user
    @user = User.find_by_id(params[:id])
    return not_authenticated unless current_api_user == @user
  end

  def register_params
    begin
      params.require(:user).permit(UserRegisterForm::PARAMS)
    rescue ActionController::ParameterMissing => e
      {}
    end
  end

end
