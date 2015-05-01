class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!
  before_action :authorize_admin
  before_filter :configure_sign_up_params, only: [:create, :admin_create]
# before_filter :configure_account_update_params, only: [:update]
  
  respond_to :html, :json

  def index 
    respond_to do |format|
      format.html {}
      format.json {render json: User.classify_by_roles}
    end
  end

  def users_index
    users = User.get_non_admins params
    respond_to do |format|
      format.json{render json: {users: users}}
    end
  end

  def admins_index
    admins = User.get_admins
    respond_to do |format|
      format.json{render json: {admins: admins}}
    end
  end
  
  # GET /resource/sign_up
  def new
    super
  end

  # POST /resource
  def create
    super
  end

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  def update
    super
  end

  # DELETE /resource
  def destroy
    super
  end

  def show
    respond_to do |format|
      format.json {render json: {user: User.find(params[:id])}}
    end
  end

  def mass_new
  end

  def mass_create
    unless params[:users]
      flash[:alert] = "Please select spreadsheet"
      redirect_to users_mass_new()
    end

    report_json = User.mass_create params[:users]

    respond_to do |format|
      format.html{ render json: report_json }
      format.json{ render json: report_json }
    end
  end

  def admin_new
  end

  def admin_create
    user = User.create_admin params[:admin]
    if user
      message = "Admin successfully created"
    else
      message = "Admin creation failed"
    end
    respond_to do |format|
      format.html {
        if user
          flash[:notice] = message 
          redirect_to users_path 
        else
          flash[:alert] = message
          redirect_to users_admin_new_path
        end
      }
      format.json {render json: {reply: message, id: user.id}}
    end
  end

  def admin_destroy
    user = User.find params[:id]
    if user.destroy
      message = "User successfully removed"
    else
      message = "Error in removing user"
    end
    respond_to do |format|
      format.html {render json: {reply: message}}
      format.json {render json: {reply: message}}
    end
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    super
  end

  protected

  # You can put the params you want to permit in the empty array.
  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) << User.column_names
  end

  # You can put the params you want to permit in the empty array.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  private

  def authorize_admin
    authorize! :manage, :site, :message => "Only admin can access this url."
  end
end
