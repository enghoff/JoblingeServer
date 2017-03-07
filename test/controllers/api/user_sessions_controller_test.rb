require "test_helper"

describe Api::UserSessionsController do

  describe "#create" do
    it "returs a user with its auth_token and game data if the credentials are correct and has been registered" do
      user = Fabricate(:user_with_game_data)
      user.register!
      post :create, {email: user.email, password: "qwerty"}
      assert_response 200
      assert parsed_json_response["auth_token"].present?
      assert parsed_json_response["email"].present?
      assert parsed_json_response["nickname"].present?
      assert parsed_json_response["location"].present?
      assert parsed_json_response["location"]["id"].present?
      assert parsed_json_response["location"]["name"].present?
      assert parsed_json_response["group"].present?
      assert parsed_json_response["group"]["id"].present?
      assert parsed_json_response["group"]["name"].present?
      assert parsed_json_response["gender"].present?
      assert parsed_json_response["birth_date_year"].present?
      assert parsed_json_response["birth_date_month"].present?
      assert parsed_json_response["birth_date_day"].present?
      assert parsed_json_response["password"].blank?
      assert parsed_json_response["game_data"].key?("data")
    end
    it "returs a message of invalid credentials if they are incorrect and has been registered" do
      user = Fabricate(:user)
      user.register!
      post :create, {email: user.email, password: "false"}
      assert_response 401
      assert_equal parsed_json_response["message"], "Invalid credentials"
    end
    it "returs a message of registration pending if it has not been registered" do
      user = Fabricate(:user)
      post :create, {email: user.email, password: "qwerty"}
      assert_response 412
      assert_equal parsed_json_response["message"], "Registration pending"
    end
  end

  describe "#reset" do
    it "attempts to change the auth token" do
      user = Fabricate(:user)
      auth_token = user.auth_token
      delete :reset, { auth_token: auth_token }
      assert_response 200
      assert_not_equal auth_token, user.reload.auth_token
      assert_equal parsed_json_response["message"], "Auth token reset successful"
    end
  end

end
