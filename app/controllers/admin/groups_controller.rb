class Admin::GroupsController < AdminController
  before_filter :find_resource, only: %i[edit update destroy]

  def index
    @search = Search.new(
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
    @resource = klass.new
  end

  def edit
  end

  def create
    @resource = klass.new(resource_params)
    authorize @resource
    if @resource.save
      redirect_to admin_groups_path, notice: "Group successfully created"
    else
      render :new
    end
  end

  def update
    @resource.attributes = resource_params
    authorize @resource
    if @resource.save
      redirect_to admin_groups_path, notice: "Group successfully updated"
    else
      render :edit
    end
  end

  def destroy
    authorize @resource
    @resource.destroy
    redirect_to admin_groups_path, notice: "Group successfully deleted"
  end

  private

  def klass
    Group
  end

  def find_resource
    @resource = klass.find(params[:id])
  end

  def resource_params
    params.require(:group).permit([:name])
  end

  def search_attributes
    [:name]
  end

  rescue_from 'ActiveRecord::InvalidForeignKey' do
    redirect_to admin_groups_path, alert: "The group can't be deleted since it is referenced by other records."
  end

end
