class UserPolicy
  attr_reader :user, :user_object

  def initialize(user, user_object)
    @user = user
    @user_object = user_object
  end

  def modify_role?
    user.admin?
  end

  def create?
    # admin can create all types
    return true if user.admin?
    # manager can only create players
    if user_object.instance_of? User
      user_object.role == "player"
    elsif user_object.is_a? User
      true
    else
      false
    end
  end

  def update?
    # an admin can update all types
    return true if user.admin?
    # a manager can not change roles
    return false if user_object.role_changed?
    # a manager can update players and himself
    return true if same_user || user_object.player?
  end

  def destroy?
    # you can't destroy yourself
    return false if same_user
    # an admin can destroy all types
    return true if user.admin?
    # a manager can only destroy players
    user_object.player?
  end

  private

  def same_user
    user == user_object
  end

end
