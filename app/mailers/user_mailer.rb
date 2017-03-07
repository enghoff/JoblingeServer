class UserMailer < ActionMailer::Base
  def registration_needed_email(user)
    @user = UserDecorator.decorate(user)
    @app_store_download_link   = Rails.configuration.x.settings[:external_game_routes][:app_store_download_link]
    @google_play_download_link = Rails.configuration.x.settings[:external_game_routes][:google_play_download_link]
    @registration_code         = @user.registration_code
    mail(:to => user.email,
         :subject => Rails.configuration.x.settings[:mails][:user_registration_title])
  end

  def reset_password_email(user)
    @user = user
    @url  = edit_password_reset_url(user.reset_password_token, protocol: :https)
    mail(:to => user.email,
         :subject => Rails.configuration.x.settings[:mails][:user_password_reset_title])
  end

end
