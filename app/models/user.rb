class User < ActiveRecord::Base

  has_one :game_data
  belongs_to :group
  belongs_to :location
  has_many :player_sessions

  enum role:   { player: 0, manager: 1, admin: 2 }

  enum gender: { female: 0, male: 1 }


  attr_accessor :password, :password_confirmation, :_require_password_once
  # this validations go here instead of in the user_validations to play nice with
  # the sorcery change_password! method
  include PasswordValidations

  authenticates_with_sorcery!

  before_create :set_auth_token
  before_create :set_registration_code

  def self.find_for_registration_code(code)
    code = code.to_s.downcase.gsub(/[^\h]+/,"") # remove non-hex chars
    User.find_by_registration_code(code)
  end

  def reset_auth_token!
    self.auth_token = nil
    set_auth_token
    save(validate:false) # skip password validation
  end

  def manager_or_admin?
    self.manager? || self.admin?
  end

  def full_name
    self.nickname
  end

  def birth_date_year
    self.birth_date.try(:year)
  end

  def birth_date_month
    self.birth_date.try(:month)
  end

  def birth_date_day
    self.birth_date.try(:day)
  end

  def registered?
    !registration_pending?
  end

  def registration_pending?
    self.registered_at.blank?
  end

  def register!
    self.update_attributes!(registered_at:DateTime.now)
  end

  def require_password_once
    self._require_password_once = true
  end

  private

  def set_auth_token
    self.auth_token ||= SecureRandom.hex(127)
  end

  def set_registration_code
    # Ex: "f1948c5569c5"
    self.registration_code ||= SecureRandom.hex(6)
  end
end
