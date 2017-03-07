class UserLoggedConstraint
  def current_user(request)
    User.find_by_id(request.session[:user_id])
  end

  def matches?(request)
    current_user(request).present?
  end
end
