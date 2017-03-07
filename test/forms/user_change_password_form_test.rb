require "test_helper"

describe UserChangePasswordForm do
  describe "#valid?" do
    before do
      @user = Fabricate(:user)
      @form = UserChangePasswordForm.new(record: @user)
    end

    it "needs a valid password" do
      assert_error_on(@form, :password)
      @form.password = "123"   # not valid
      assert_error_on(@form, :password)
      @form.password = "12345" # valid one
      refute_error_on(@form, :password)
    end

    it "validates with all the right params" do
      @form.password = "12345"
      assert @form.valid?
    end
  end

  describe "#save" do
    it "changes the password" do
      user  = Fabricate(:user, password:"qwerty")
      model = UserChangePasswordForm.new(record:user, password:"qwerty2")
      user = model.save
      assert user.valid_password?("qwerty2")
    end
  end

end
