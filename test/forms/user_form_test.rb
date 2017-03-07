require "test_helper"
require "forms/shared_user_form_test"

describe UserForm do

  let(:manager){ Fabricate(:user, role:"manager")}
  let(:admin){   Fabricate(:user, role:"admin")}
  let(:group){ Fabricate(:group) }
  # location would overwrite a method from minitest http://apidock.com/ruby/v1_9_3_392/MiniTest/Unit/location
  let(:user_location){ Fabricate(:location) }

  describe "#valid?" do
    before do
      @form = UserForm.new
      @form.policy_user = manager
    end

    include SharedUserFormTest

    it "needs a valid password if present" do
      @form.password = "123"   # not valid
      assert_error_on(@form, :password)
      @form.password = "12345" # valid one
      refute_error_on(@form, :password)
    end

    it "needs a valid nickname if present" do
      refute_error_on(@form, :nickname)
      existing_nickname = Fabricate(:user).nickname
      @form.nickname = existing_nickname
      refute_error_on(@form, :nickname) # now it has to allow duplicates
      @form.nickname = "Peter"
      refute_error_on(@form, :nickname)
    end

    it "validates with all the right params" do
      model = UserForm.new(valid_signup_params)
      assert model.valid?
    end

    it "doesn't allow you to set other role than player if you are not an admin" do
      # It won't let a manager create a new admin user
      model = UserForm.new(valid_signup_params)
      model.policy_user = manager
      model.role = "admin"
      assert_raises Pundit::NotAuthorizedError do
        model.save
      end
      model.policy_user = admin
      assert model.save
      assert_equal model.resource.reload.role, "admin"

      # It won't let a manager update an admin user
      model.role = "player"
      model.policy_user = manager
      assert_raises Pundit::NotAuthorizedError do
        model.save
      end
      model.policy_user = admin
      assert model.save
      assert_equal model.resource.reload.role, "player"
    end

    it "doesn't allow you to modify other users than players unless you are an admin" do
      model = UserForm.new(valid_signup_params)
      model.role = "admin"
      model.policy_user = admin
      model.save
      model.nickname = "foo"
      model.save
      assert_equal model.resource.reload.nickname, "foo"
      model.policy_user = manager
      assert_raises Pundit::NotAuthorizedError do
        model.save
      end
    end
  end

  describe "#persist" do
    it "persists the model with the right information" do
      model = UserForm.new(valid_signup_params)
      model.policy_user = manager
      user = model.save
      assert user.persisted?, "user not persisted"
      user.reload
      valid_signup_params.except(
        :password,
        :birth_date_day,
        :birth_date_month,
        :birth_date_year,
      ).each do |field, value|
        assert_equal user[field], value
      end
      date = Date.new(
        valid_signup_params[:birth_date_year],
        valid_signup_params[:birth_date_month],
        valid_signup_params[:birth_date_day],
      )
      assert_equal user.birth_date, date
      assert user.valid_password?("qwerty")
    end
  end

  describe "#create" do
    it "persists the model and creates a game data" do
      model = UserForm.new(valid_signup_params)
      model.policy_user = manager
      user = model.create
      assert user.persisted?, "user not persisted"
      assert user.game_data.present?
    end
  end

  describe "#create_and_send_registration_mail" do
    it "persists the model and sends the mail with the code" do
      ActionMailer::Base.deliveries.clear
      model = UserForm.new(valid_signup_params)
      model.policy_user = manager
      user = model.create_and_send_registration_mail
      assert user.persisted?, "user not persisted"
      assert ActionMailer::Base.deliveries.present?
      mail = ActionMailer::Base.deliveries.last
      assert_equal mail.subject, Rails.configuration.x.settings[:mails][:user_registration_title]
      assert_match(Rails.configuration.x.settings[:external_game_routes][:app_store_download_link],   mail.text_part.body.to_s)
      assert_match(Rails.configuration.x.settings[:external_game_routes][:google_play_download_link], mail.text_part.body.to_s)
      assert_match(Rails.configuration.x.settings[:external_game_routes][:app_store_download_link],   mail.html_part.body.to_s)
      assert_match(Rails.configuration.x.settings[:external_game_routes][:google_play_download_link], mail.html_part.body.to_s)
      assert_match(user.decorate.registration_code, mail.text_part.body.to_s)
      assert_match(user.decorate.registration_code, mail.html_part.body.to_s)
    end
  end

end
