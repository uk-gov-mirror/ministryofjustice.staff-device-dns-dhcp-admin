class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def new_session_path(scope)
    new_user_session_path
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to main_app.root_path, notice: exception.message }
    end
  end

  private

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
