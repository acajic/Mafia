class ApplicationController < ActionController::Base
  include ApipieParams::Auth

  #protect_from_forgery

  @@auth_tokens_cache_hash = {}
  @@auth_tokens_cache_array = []


  def handle_options_request
    head(:ok) if request.request_method == 'OPTIONS'
  end

  protected

  def optional_authorization
    @authorized_user = nil
    confirm_authorization([], false)
  end

  def confirm_authorization(app_permissions = [], is_required = true)
    if params[:auth_token].nil? || params[:auth_token].empty?
      if is_required
        render json: 'auth_token key not present', status: :unauthorized
        return false
      else
        return true
      end
    end

    auth_token = nil
    auth_token_string = params.require(:auth_token)
    if @@auth_tokens_cache_hash[auth_token_string]
      @@auth_tokens_cache_array.delete(auth_token_string)
      @@auth_tokens_cache_array.insert(0, auth_token_string)

      auth_token = @@auth_tokens_cache_hash[auth_token_string]
    else
      auth_token = AuthToken.where(:token_string => auth_token_string).first
      if auth_token.nil?
        if is_required
          render json: 'auth_token ' + auth_token_string + ' is invalid.', status: :unauthorized
          return false
        else
          return true
        end

      end
    end

    datetime_now = Time.now.utc
    if auth_token.expiration_date > datetime_now
      auth_token.last_accessed = datetime_now

      @@auth_tokens_cache_hash[auth_token_string] = auth_token
      @@auth_tokens_cache_array.insert(0, auth_token_string)

      while @@auth_tokens_cache_array.length > AUTH_TOKEN_CACHE_BUFFER_SIZE
        removed_auth_token_string = @@auth_tokens_cache_array.delete_at(AUTH_TOKEN_CACHE_BUFFER_SIZE)
        @@auth_tokens_cache_hash.delete(removed_auth_token_string)
      end

      if app_permissions.nil?
        @authorized_user = auth_token.user
      else
        auth_token.user.app_role = nil # force refreshing of app_role
        auth_token.user.app_permissions = nil # force refreshing of app_role

        users_app_permission_ids = auth_token.user.app_permissions.map { |app_permission| app_permission.id}
        permissions_not_granted = app_permissions - users_app_permission_ids
        if permissions_not_granted.count == 0
          # all good, all permission are granted
          @authorized_user = auth_token.user
        else
          if is_required
            not_granted_app_permission_names = AppPermission.find(permissions_not_granted).map { |app_permission| app_permission.name }.join(', ')
            render json: 'Permissions not granted: ' + not_granted_app_permission_names, status: :unauthorized
            return false
          else
            return true
          end

        end
      end

    else
      @@auth_tokens_cache_hash.delete(auth_token_string)
      @@auth_tokens_cache_array.delete(auth_token_string)

      auth_token.destroy

      if is_required
        render json: 'auth_token expired', status: :unauthorized
        return false
      else
        return true
      end
    end


  end

  private

  AUTH_TOKEN_CACHE_BUFFER_SIZE = 10


  after_filter :set_access_control_headers

  def set_access_control_headers
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept'
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE'
  end


end
