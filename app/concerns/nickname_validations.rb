module NicknameValidations
  extend ActiveSupport::Concern

  included do
    validates :nickname, presence: true, :if => :nickname_required?

    private

    def nickname_required?
      false
    end

  end
end
