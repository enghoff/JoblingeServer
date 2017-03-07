ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'


require "minitest/rails"
require "minispec-metadata"
require 'database_cleaner'
require 'shoulda'
require 'shoulda/matchers'
require 'mocha/mini_test'
require "minitest/autorun"
# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

require "minitest/pride"


ActiveRecord::Migration.check_pending!
ActiveSupport::TestCase.test_order = :random
# Protractor test or even some dirty debugging in the rails console on test environment
# might have left some garbage on the DB. Lets make sure we start with a clean state.
DatabaseCleaner.clean_with(:truncation)

class Minitest::Spec
  before :each do |example|
    Rails.cache.clear
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end
end

def parsed_json_response
  JSON.parse(response.body)
rescue Oj::ParseError
  {}
end

def current_user
  @controller.send(:current_user)
end

def assert_error_on(model, field, msg = nil)
  msg = message(msg) { "Expected #{model} to be have an error on #{field}, but got none." }
  model.valid?
  assert model.errors.messages[field].present?, msg
end

def refute_error_on(model, field, msg = nil)
  msg = message(msg) { "Expected #{model} to not have an error on #{field}, but got #{model.errors.messages[field]}." }
  model.valid?
  assert model.errors.messages[field].blank?, msg
end

def valid_signup_params
  @valid_signup_params ||= begin
    group    = Fabricate(:group)
    location = Fabricate(:location)
    Fabricate
      .build(:user)
      .attributes
      .with_indifferent_access
      .slice(*UserForm::PARAMS)
      .merge(
        password: "qwerty",
        birth_date_day:   10,
        birth_date_month: 11,
        birth_date_year:  2000,
        group_id: group.id,
        location_id: location.id
      )
    end
end

def valid_user_api_update_params
  @valid_signup_params ||= Fabricate
    .build(:user)
    .attributes
    .with_indifferent_access
    .slice(*UserRegisterForm::PARAMS)
    .merge(
      password: "qwerty",
    )
end
