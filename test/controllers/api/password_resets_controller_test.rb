require "test_helper"

describe Api::PasswordResetsController do
  describe "#create" do
    it "sends a password reset email if valid email" do
      ActionMailer::Base.deliveries.clear
      user = Fabricate(:user)
      user.register!
      post :create, {email: user.email}
      assert_response 200
      assert_equal parsed_json_response["message"], "Instructions have been sent to your email"
      assert ActionMailer::Base.deliveries.present?
      mail = ActionMailer::Base.deliveries.last
      user.reload
      assert_equal mail.subject, Rails.configuration.x.settings[:mails][:user_password_reset_title]
      url  = "/password_resets/%s/edit" % user.reset_password_token
      assert_match(url, mail.html_part.body.to_s)
      assert_match(url, mail.text_part.body.to_s)
    end
  end

  describe "#update" do
    it "changes the password with a valid token and a password with its confirmation" do
      user = Fabricate(:user)
      user.generate_reset_password_token!
      params = {
        token: user.reset_password_token,
        user: {
          password: "qwerty",
          password_confirmation:"qwerty"
        }
      }
      patch :update, params
      assert_response 200
      assert_equal parsed_json_response["message"], "Password was successfuly updated."
    end
    it "returns an invalid password message with right token but wrong params" do
      user = Fabricate(:user)
      user.generate_reset_password_token!
      params = {
        token: user.reset_password_token,
        user: {
          password: "qwerty",
          password_confirmation:"qwwerty"
        }
      }
      patch :update, params
      assert_response 422
      assert_equal parsed_json_response["message"], "Invalid password change"
      params = {
        token: user.reset_password_token,
        user: {
          password: "",
          password_confirmation:""
        }
      }
      patch :update, params
      assert_response 422
      assert_equal parsed_json_response["message"], "Invalid password change"
    end
  end
end
