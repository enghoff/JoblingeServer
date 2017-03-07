class UserSessionsController < ApplicationController
  skip_before_filter :require_login, :only => [:create, :new]

  def create
    user = User.find_by_email(params[:email])
    if user.try(:manager_or_admin?) && login(params[:email],params[:password],params[:remember])
      redirect_back_or_to(admin_root_path)
    else
      flash.now[:alert] = "Login failed."; render :action => "new"
    end
  end

  def destroy
    logout
    redirect_to(root_path)
  end

end
