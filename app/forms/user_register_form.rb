class UserRegisterForm
  PARAMS = [
    :nickname,
    :password,
  ]

  include Virtus.model
  include ActiveModel::Model

  attribute :password, String
  attribute :nickname,  String
  attribute :record, User

  include PasswordValidations
  include NicknameValidations

  def password_required?
    true
  end

  def nickname_required?
    true
  end

  def resource
    @resource ||= record
  end

  def id
    resource.id
  end

  def update_and_register
    save && register
  end

  def save
    if valid?
      resource.save!
      resource
    else
      false
    end
  end

  def register
    resource.register!
  end

  def assign_values
    resource.nickname   = nickname
    resource.password   = password
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
