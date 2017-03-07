class UserForm
  PARAMS = [
    :email,
    :nickname,
    :gender,
    :role,
    :location_id,
    :group_id,
    :password,
    :birth_date_day,
    :birth_date_month,
    :birth_date_year,
  ]

  include Virtus.model
  include ActiveModel::Model

  attribute :email, String
  attribute :password, String
  attribute :nickname,  String
  attribute :gender
  attribute :role
  attribute :location_id, String
  attribute :group_id, String
  attribute :birth_date, Date
  attribute :birth_date_day, Integer
  attribute :birth_date_month, Integer
  attribute :birth_date_year, Integer
  attribute :record, User
  attribute :policy_user

  attr_accessor :resource

  include UserValidations
  include PasswordValidations
  include NicknameValidations

  def password_required?
    false
  end

  def nickname_required?
    false
  end

  def gender=(gender)
    # accept both string and integer value for gender enums, use number
    # User.genders => {"female"=>0, "male"=>1}
    gender_is_numeric = gender.to_i.to_s == gender.to_s
    gender = gender.to_i if gender_is_numeric
    @gender = gender_is_numeric ? gender : User.genders[gender]
  end

  def role=(role)
    # accept both string and integer value for role enums, use number
    # User.roles => {"player"=>0, "manager"=>1, "admin"=>2}
    role_is_numeric = role.to_i.to_s == role.to_s
    role = role.to_i if role_is_numeric
    @role = role_is_numeric ? role : User.roles[role]
  end

  def birth_date
    Date.new( birth_date_year, birth_date_month, birth_date_day ) rescue nil
  end

  def resource
    @resource ||= (record || User.new)
  end

  def id
    resource.id
  end

  def create_and_send_registration_mail
    if create
      UserMailer.registration_needed_email(resource).deliver_now
      resource
    else
      false
    end
  end

  def create
    if save
      create_game_data
      resource
    else
      false
    end
  end

  def update
    save
  end

  def register
    resource.register!
  end

  def save
    if valid?
      verify_policy
      resource.save!
      resource
    else
      false
    end
  end

  def create_game_data
    GameData.create!(user_id:resource.id)
  end

  def assign_values
    resource.email         = email
    resource.nickname      = nickname
    resource.location_id   = location_id
    resource.group_id      = group_id
    resource.gender        = gender
    resource.password      = password
    resource.birth_date    = birth_date
    resource.role          = role if role # might not be submitted
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

  def verify_policy
    operation = resource.new_record? ? :create? : :update?
    policy = UserPolicy.new( policy_user, resource)
    raise Pundit::NotAuthorizedError unless policy.send(operation)
  end

end
