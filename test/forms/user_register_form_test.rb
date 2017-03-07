require "test_helper"

describe UserRegisterForm do
  describe "#valid?" do
    before do
      @user = Fabricate(:user)
      @form = UserRegisterForm.new(record: @user)
    end

    it "needs a valid nickname" do
      assert_error_on(@form, :nickname)
      existing_nickname = Fabricate(:user).nickname
      @form.nickname = existing_nickname
      refute_error_on(@form, :nickname) # now we want to allow duplicates
      @form.nickname = "Peter"
      refute_error_on(@form, :nickname)
    end

    it "needs a valid password" do
      assert_error_on(@form, :password)
      @form.password = "123"   # not valid
      assert_error_on(@form, :password)
      @form.password = "12345" # valid one
      refute_error_on(@form, :password)
    end

    it "validates with all the right params" do
      model = UserRegisterForm.new(valid_user_api_update_params.merge(record:@user))
      assert model.valid?
    end
  end

  describe "#save" do
    it "persists the model with the right information" do
      user  = Fabricate(:user)
      model = UserRegisterForm.new(valid_user_api_update_params.merge(record:user, password:"qwerty2"))
      user = model.save
      assert user.persisted?, "user not persisted"
      user.reload
      valid_signup_params.except(
        :password,
      ).each do |field, value|
        assert_equal user[field], value
      end
      assert user.valid_password?("qwerty2")
    end
  end

end
