require "test_helper"

describe User do

  describe ".find_for_registration_code" do
    it "finds the user given different code formats" do
      user = Fabricate(:user, registration_code:"123a")
      assert_equal User.find_for_registration_code("123a"), user
      assert_equal User.find_for_registration_code(" 123A"), user
      assert_equal User.find_for_registration_code(" 1 23A "), user
      assert_equal User.find_for_registration_code("1-23%%   A"), user
    end
  end

  describe "#set_registration_code" do
    it "sets the registration code before creating a new record" do
      user = Fabricate(:user)
      assert user.registration_code.present?
    end
  end

end
