module UserValidations
  extend ActiveSupport::Concern

  VALID_CITIES = Rails.configuration.x.settings[:cities]

  included do

    validates :email, presence: true
    validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
    validate :email_must_be_unique

    validate :valid_group
    validate :valid_location

    validates :gender, presence: true
    validates :gender, inclusion: { in: User.genders.values }

    validates :birth_date, presence: true
    validate  :birth_date_fields

    private

    def email_must_be_unique
      if User.where(email: email).where.not(id:self.id).count >= 1
        errors.add(:email, I18n.t("errors.messages.taken"))
      end
    end

    def birth_date_fields
      unless self.birth_date
        errors.add(:birth_date_day, "")
        errors.add(:birth_date_month, "")
        errors.add(:birth_date_year, "")
      end
    end

    def valid_group
      errors.add(:group_id, "is invalid.") unless Group.find_by_id(self.group_id)
    end

    def valid_location
      errors.add(:location_id, "is invalid.") unless Location.find_by_id(self.location_id)
    end
  end
end
