class AppRolesController < ApplicationController

  # GET /app_roles
  # GET /app_roles.json
  before_filter(:only => :index) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  def index
    @app_roles = AppRole.all

    

    unless params[:page_index].nil? || params[:page_size].nil?
      page_index = params[:page_index].to_i()
      page_size = params[:page_size].to_i()
      @app_roles = @app_roles.limit(page_size).offset(page_size*page_index)
    end

    render json: @app_roles
  end

end
