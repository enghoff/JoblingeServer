class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :require_login, :except => [:not_authenticated]

  protected

  def not_authenticated
    respond_to do |format|
      format.json{render :json => {redirect_to: "/"}}
      format.html{redirect_to "/", :alert => "Please login first." }
    end
  end
end
