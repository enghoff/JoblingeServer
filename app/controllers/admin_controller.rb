class AdminController < ApplicationController
  layout "admin"
  before_filter :authenticate_admin

  def authenticate_admin
    if !current_user.try(:manager_or_admin?)
      logout if current_user
      not_authenticated
    end
  end

  rescue_from Pundit::NotAuthorizedError, with: :not_allowed

  private

  def require_admin
    not_allowed unless current_user.admin?
  end

  def not_allowed
    redirect_to admin_users_path, {alert: "Not allowed."}
  end

end
