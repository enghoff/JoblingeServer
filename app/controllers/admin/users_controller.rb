class Admin::UsersController < AdminController
  before_filter :find_resource, only: %i[edit update destroy resend_registration_mail statistics progress]

  def index
    @search = UserSearch.new(
      klass:klass,
      search_attributes: search_attributes,
      term: params[:term],
      page: params[:page],
      sort_column: params[:sort_column],
      sort_direction: params[:sort_direction],
      default_sort_column: :created_at,
      default_sort_direction: :desc,
    )
    @resources = @search.run
  end

  def new
    @resource = UserForm.new.resource
  end

  def edit
  end

  def statistics
    @stats = PlayerSessionStats.new(user:@resource, grouped_by: params[:grouped_by])
  end

  def progress
    world_config = Rails.configuration.x.settings[:world_config]
    @user_progress = UserProgress.new(data:@resource.game_data.data, world_config:world_config)
  end

  def create
    form = UserForm.new(resource_params)
    form.policy_user = current_user
    if form.create_and_send_registration_mail
      redirect_to admin_users_path, notice: "User successfully created"
    else
      @resource = form.resource
      render :new
    end
  end

  def update
    form = UserForm.new(resource_params)
    form.policy_user = current_user
    form.record = @resource
    if form.update
      redirect_to admin_users_path, notice: "User successfully updated"
    else
      @resource = form.resource
      render :edit
    end
  end

  def destroy
    authorize @resource
    @resource.destroy
    redirect_to admin_users_path, notice: "User successfully deleted"
  end

  def resend_registration_mail
    UserMailer.registration_needed_email(@resource).deliver_now
    redirect_to admin_users_path, notice: "Registration instructions sent."
  end

  private

  def klass
    User
  end

  def find_resource
    @resource = klass.find(params[:id]).decorate
  end

  def resource_params
    params.require(:user).permit(*UserForm::PARAMS)
  end

  def search_attributes
    [:nickname, :email, :location_name, :group_name]
  end

end
