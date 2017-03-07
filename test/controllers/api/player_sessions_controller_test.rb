require "test_helper"

describe Api::PlayerSessionsController do
  describe "#create" do
    it "saves the player session for the current user if the time stamp is correct" do
      user = Fabricate(:user)
      started_at = Time.now
      player_session_params = { started_at: started_at, finished_at: Time.now + 20.minutes }
      post :create, {auth_token: user.auth_token, player_session: player_session_params}
      assert_response 200
      assert_equal parsed_json_response["duration_in_seconds"], 20 * 60
      assert_equal parsed_json_response["id"], user.player_sessions(true).last.id
    end
    it "returns an error if the time stamp is correct" do
      user = Fabricate(:user)
      started_at = Time.now
      player_session_params = { started_at: started_at, finished_at: Time.now - 20.minutes }
      post :create, {auth_token: user.auth_token, player_session: player_session_params}
      assert_response 422
      assert_equal parsed_json_response["message"], "Invalid Player Session."
    end
  end

  describe "#update" do
    it "updates a player session with the given data if valid" do
      user = Fabricate(:user_with_play_sessions)
      previous_session = user.player_sessions.last
      started_at = previous_session.started_at
      player_session_params = { started_at: started_at, finished_at: Time.now + 20.minutes }
      put :update, {
        id: previous_session.id,
        auth_token: user.auth_token,
        player_session: player_session_params
      }
      assert_response 200
    end

    it "creates a player session with the given data if valid and the record didn't exist" do
      user = Fabricate(:user)
      another_id = SecureRandom.hex
      started_at = Time.now
      player_session_params = { started_at: started_at, finished_at: Time.now + 20.minutes }
      put :update, {
        id: another_id,
        auth_token: user.auth_token,
        player_session: player_session_params
      }
      assert_response 200
      assert user.reload.player_sessions.find_by_id(another_id)
    end

    it "returns unauthorized if the player session belongs to another user" do
      user = Fabricate(:user_with_play_sessions)
      another_user = Fabricate(:user)
      previous_session = user.player_sessions.last
      started_at = previous_session.started_at
      player_session_params = { started_at: started_at, finished_at: Time.now + 20.minutes }
      put :update, {
        id: previous_session.id,
        auth_token: another_user.auth_token,
        player_session: player_session_params
      }
      assert_response 401
      assert parsed_json_response["message"], "Invalid authorization token"
    end

    describe "#index" do
      it "returns the list of player_sessions for the curren user order by finished_at dec" do
        user = Fabricate(:user_with_play_sessions)
        get :index, { auth_token: user.auth_token }
        assert_response 200
        assert parsed_json_response.first.has_key?("duration_in_seconds")
        first = PlayerSession.find(parsed_json_response.first["id"])
        second = PlayerSession.find(parsed_json_response.second["id"])
        assert first.finished_at >= second.finished_at
      end
    end

    describe "#show" do
      it "returns the given player session" do
        user = Fabricate(:user_with_play_sessions)
        get :show, { id: user.player_sessions.first.id, auth_token: user.auth_token }
        assert_response 200
        assert parsed_json_response.has_key?("duration_in_seconds")
      end
      it "returns 404 if not found" do
        user = Fabricate(:user)
        get :show, { auth_token: user.auth_token, id: "123" }
        assert_response 404
        assert_equal parsed_json_response["message"], "Player Session not found"
      end
    end

    describe "#destroy" do
      it "deletes the given player session" do
        user = Fabricate(:user_with_play_sessions)
        sessions_count = user.player_sessions.count
        delete :destroy, { id: user.player_sessions.first.id, auth_token: user.auth_token }
        assert_response 200
        assert_equal parsed_json_response["message"], "Player Session deleted"
        assert_equal user.player_sessions.count, sessions_count - 1
      end
      it "returns 404 if not found" do
        user = Fabricate(:user)
        delete :destroy, { id: "123", auth_token: user.auth_token }
        assert_response 404
        assert_equal parsed_json_response["message"], "Player Session not found"
      end
    end
  end
end
