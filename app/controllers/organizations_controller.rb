class OrganizationsController < ApplicationController
  before_filter :only => [:show, :edit, :update, :destroy, :participation_request, :deactivate] do
    @organization = Organization.find_by_slug!(params[:id])
  end
  # def to_param
  #   "#{id}-#{title.parameterize}"
  # end

  def index
    # @organization_categories = OrganizationCategory.all.where(active: true).where.not(name: 'Донорская помощь')
    # @donor = OrganizationCategory.find_by(name: 'Донорская помощь')
    # @organizations = Organization.all.where(active: true).where.not(organization_category_id: @donor.id)

    @posts = Post.all.where(post_category_id:1)
    @posts = Post.all.order(created_at: :desc).last(3)
    @organization_categories = OrganizationCategory.all.where(active: true)
    @organizations  =  Organization.all.order(created_at: :desc).last(3)
  end

  def new
    # @organization = Organization.new
    if organization_params
      # If data submitted already by the form we call the create method
      create
      return
    end

    @organization = Organization.new

    render 'new' # call it explicit
  end

  def create
    @organization = Organization.new(organization_params)
    if @organization.save
      UserMailer.welcome_email(AdminUser.first,@organization.id,@organization.name,current_user).deliver_now
      flash[:success] = t(".create")
      @user_organization = UserOrganization.create!(organization_id: @organization.id,
                                                    user_id: current_user.id, role: 1,approved: true)
      redirect_to root_path
    else
      render 'new'
    end
  end

  def participation_request
    # @organization = Organization.find(params[:id])
    @user_organization = UserOrganization.new(organization_id: @organization.id,
                                              user_id: current_user.id, role: 2,approved: false)
    if @user_organization.save
      flash[:success] = t(".success")
      redirect_to root_path
    end

  end

  def approved
    @user_organization = UserOrganization.find(params[:id])
    @user_organization.update(approved: true)
    flash[:success] = t(".success")
    redirect_to root_path

  end

  def edit
    # @organization = Organization.find(params[:id])
  end

  def update
    # @organization = Organization.find(params[:id])
    if @organization.update(organization_params)
      redirect_to organizations_list_path
    else
      render 'edit'
    end
  end

  def deactivate
    # @organization = Organization.find(params[:id])
    @organization.update_attribute(:active, false)

    flash[:success] = t(".deactivate")
    redirect_to root_path
  end

  def list
    @organization_categories = OrganizationCategory.all.where(active: true).where.not(name: 'Доноры')
    @organizations_all = Organization.all.where(active: true).page(params[:page]).per(3).order('created_at desc')
    @organizations = Organization.where(active: true).select([:id, :name, :latitude, :longitude, :description, :address, :slug])
    @help_requests = Post.where(post_category_id: 1).select([:id, :title, :body, :organization_id,:slug]).group(:organization_id).order('created_at desc')
    respond_to do |format|
      format.html
      format.js {}
      format.json {
        render json: {
            :organizations => @organizations,
            :posts => @help_requests
        }
      }
    end
  end

  def destroy
    # @organization=Organization.find(params[:id])
    @organization.destroy
    redirect_to :back
    # @organization.destroy
    # if @organization.delete
    #   flash[:success] ='organization has been deleted'
    # else
    #   render @organization
    # end
  end

  def filter_organizations
    @organization_category = OrganizationCategory.find(params[:id])
    @organization_by_category = Organization.where(organization_category_id: @organization_category)
    respond_to do |format|
      format.html
      format.js {}
      format.json {
        render json: {
            :organizations => @organization_by_category
        }
      }
    end
  end

  def donors
    if OrganizationCategory.exists?
      @donor = OrganizationCategory.find_by(name: 'Доноры')
      @organizations = Organization.all.where(active: true).where(organization_category_id: @donor.id)
    else
      render file: 'public/404', status: 404, formats: [:html]
    end
  end

  def show
    # @organization = Organization.find_by(slug: params[:id])
    @org_user = @organization.user_organizations.find_by(organization_id: @organization.id,role:1)
    @post = Post.where(organization_id: @organization.id)
    unless @org_user.nil?
      @user = @org_user.user
    end
  end

  private
  def organization_params
    if params[:organization].nil?  || params[:organization].empty?
      return false
    else
    return params.require(:organization).permit(:name, :description, :location, :phone, :address, :contact_person,
      :longitude, :latitude, :organization_category_id, :oblast_id, :url, :active, :slug)
    end
  end

  def user_organization_params
    params.require(:user_organization).permit(:role, :organization_id, :user_id, :post,:approved)
  end

end

