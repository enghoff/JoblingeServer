class Api::PasswordResetsController < ApiController
  skip_before_filter :require_auth_token

  # request password reset.
  # you get here when the user entered his email in the reset password form and submitted it.
  def create
    user = User.find_by_email(params[:email])

    # This line sends an email to the user with instructions on how to reset their password (a url with a random token)
    user.deliver_reset_password_instructions! if user

    # Tell the user instructions have been sent whether or not email was found.
    # This is to not leak information to attackers about which emails exist in the system.

    render json: { message: "Instructions have been sent to your email" }, status: 200
  end

  # This action fires when the user has sent the reset password form.
  def update
    user = User.load_from_reset_password_token(params[:token])
    return not_authenticated unless user
    user.require_password_once
    # the next line makes the password confirmation validation work
    user.password_confirmation = params[:user][:password_confirmation]
    # the next line clears the temporary token and updates the password
    if user.change_password!(params[:user][:password])
      render json: { message: "Password was successfuly updated." }, status: 200
    else
      render json: { message: "Invalid password change" }, status: :unprocessable_entity
    end
  end

end
