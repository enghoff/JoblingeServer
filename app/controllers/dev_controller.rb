class DevController < ApplicationController
  skip_before_filter :require_login
  before_filter :do_not_execute_in_production!

  def impersonate
    user = User.find(params.require(:user_id))
    auto_login(user)
    respond_to do |format|
      format.html { redirect_to "/" }
    end
  end

  private

  def do_not_execute_in_production!
    raise ActiveRecord::RecordNotFound if Rails.env.production?
  end

end
