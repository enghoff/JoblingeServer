require "test_helper"

describe Api::GameDataController do

  describe "#show" do
    it "returs the game data from the user" do
      user = Fabricate(:user_with_game_data)
      get :show, {auth_token: user.auth_token, user_id: user.id}
      assert_response 200
      assert parsed_json_response.key?("data")
    end
  end

  describe "#update" do
    it "returs an error if the game data params are not valid" do
      user = Fabricate(:user_with_game_data)
      patch :update, {auth_token: user.auth_token, user_id: user.id, game_data:{}}
      assert_response 422
      assert_equal parsed_json_response["message"], "Invalid Game Data."
    end

    it "overwrites the game data of the user and returns the data object" do
      user = Fabricate(:user_with_game_data)
      game_data_params = { data: { score: 100 } }
      patch :update, { auth_token: user.auth_token, user_id: user.id, game_data: game_data_params}
      assert_response 200
      assert_equal parsed_json_response["message"], "Game Data saved."
      assert_equal user.reload.game_data.data["score"], "100"
    end

  end

end
