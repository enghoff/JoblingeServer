require "test_helper"

describe Api::UsersController do
  include Sorcery::TestHelpers::Rails::Controller

  describe "#show" do
    it "returs a user with game data when valid id/auth_token" do
      user = Fabricate(:user_with_game_data)
      get :show, {id: user.id, auth_token: user.auth_token}
      assert_response 200
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
      assert parsed_json_response["auth_token"].present?
      assert parsed_json_response["game_data"].key?("data")
    end
    it "returs unauthorized when invalid id/auth_token" do
      user = Fabricate(:user)

      get :show, {id: "false", auth_token: user.auth_token}
      assert_response 401
    end
  end

  describe "#register" do
    it "returns unauthorized when invalid activation code" do
      user = Fabricate(:user)

      patch :register, {registration_code: "false"}
      assert_equal parsed_json_response["message"], "Invalid registration code"
      assert_response 401
    end

    it "returns precondition failed code when the user was already registered" do
      user = Fabricate(:user)
      user.register!

      patch :register, {email: user.email, registration_code: user.registration_code}
      assert_response 412
      assert_equal parsed_json_response["message"], "User already registered. Use credentials to log in."
    end

    it "returs a hash of errors if the params are invalid" do
      user = Fabricate(:user)
      patch :register, {
        email: user.email,
        registration_code: user.registration_code,
        user: {
          nickname: "", #invalid
        },
      }
      assert_response 422
      assert parsed_json_response["errors"]["nickname"].present?
    end

    it "registers the user and returns the user json if the parameters are valid" do
      user = Fabricate(:user_with_game_data)
      patch :register, {
        registration_code: user.registration_code,
        user: {
          nickname: "John",
          password: "john123"
        },
      }
      assert_response 200
      assert_equal parsed_json_response["nickname"], "John"
      assert_equal parsed_json_response["auth_token"], user.auth_token
      assert parsed_json_response["email"].present?
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
      user.reload
      assert user.registered?
      assert user.valid_password?("john123")
    end
  end

  describe "#change_password" do
    it "returs a hash of errors if the params are invalid" do
      user = Fabricate(:user)
      patch :change_password, {
        id: user.id,
        auth_token: user.auth_token,
        user: {
          password: "", #invalid
        },
      }
      assert_response 422
      assert parsed_json_response["errors"]["password"].present?
    end

    it "modifies the password if the params are valid" do
      user = Fabricate(:user)
      patch :change_password, {
        id: user.id,
        auth_token: user.auth_token,
        user: {
          password: "qwerty2", #valid
        },
      }
      assert_response 200
      assert_equal parsed_json_response["message"], "Password changed"
      user.reload
      assert user.valid_password?("qwerty2")
    end
  end

end
