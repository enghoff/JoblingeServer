module PasswordValidations
  extend ActiveSupport::Concern

  included do
    validates :password, presence: true, :if => :password_required?
    validates_length_of :password, :minimum => 5, :message => "password must be at least 5 characters long", :if => :password_present?
    validates_confirmation_of :password, :message => "should match confirmation", :if => :password_present?

    def password_required?
      if self.try(:_require_password_once)
        self._require_password_once = nil
        return true
      end
      false
    end

    def password_present?
      self.password.present?
    end

  end
end
