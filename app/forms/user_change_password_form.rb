class UserChangePasswordForm
  PARAMS = [
    :password,
  ]

  include Virtus.model
  include ActiveModel::Model

  attribute :password, String
  attribute :record, User

  include PasswordValidations

  def password_required?
    true
  end

  def resource
    @resource ||= record
  end

  def id
    resource.id
  end

  def save
    if valid?
      resource.save!
      resource
    else
      false
    end
  end

  def assign_values
    resource.password = password
  end

  def assign_errors
    self.errors.messages.each{|e,m| resource.errors.set(e, m)}
  end

  def valid?
    valid = super
    assign_values
    assign_errors
    valid
  end

end
