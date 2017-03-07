require 'active_support'

module SharedUserFormTest
  extend ActiveSupport::Concern

  included do

    it "needs a valid email" do
      assert_error_on(@form, :email)
      existing_email = Fabricate(:user).email
      @form.email = existing_email
      assert_error_on(@form, :email)
      @form.email = "foo@foo.com"
      refute_error_on(@form, :email)
    end
    it "needs a valid location" do
      assert_error_on(@form, :location_id)
      @form.location_id = -1
      assert_error_on(@form, :location_id)
      @form.location_id = user_location.id
      refute_error_on(@form, :location_id)
    end
    it "needs a valid group" do
      assert_error_on(@form, :group_id)
      @form.group_id = -1
      assert_error_on(@form, :group_id)
      @form.group_id = group.id
      refute_error_on(@form, :group_id)
    end
    it "needs a valid gender" do
      assert_error_on(@form, :gender)
      @form.gender = "blue"
      assert_error_on(@form, :gender)
      @form.gender = "male"
      refute_error_on(@form, :gender)
      @form.gender = "female"
      refute_error_on(@form, :gender)
      @form.gender = 0 #alias
      refute_error_on(@form, :gender)
      @form.gender = 1 #alias
      refute_error_on(@form, :gender)
    end
    it "needs a valid birth_date" do
      assert_error_on(@form, :birth_date)
      @form.birth_date_year = 2000
      @form.birth_date_month = 1
      @form.birth_date_day = 2
      refute_error_on(@form, :birth_date)
    end

  end
end
