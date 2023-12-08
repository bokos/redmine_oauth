module RedmineOauth
  module ApplicationControllerPatch

    def self.included(base)
      base.class_eval do
        def require_login
          if !User.current.logged?
            # Extract only the basic url parameters on non-GET requests
            if request.get?
              url = request.original_url
            else
              url = url_for(:controller => params[:controller], :action => params[:action], :id => params[:id], :project_id => params[:project_id])
            end
            respond_to do |format|
              format.html do
                if request.xhr?
                  head :unauthorized
                else
                  redirect_to oauth_path(:back_url => url)
                end
              end
              format.any(:atom, :pdf, :csv) do
                redirect_to oauth_path(:back_url => url)
              end
              format.api do
                if Setting.rest_api_enabled? && accept_api_auth?
                  head(:unauthorized, 'WWW-Authenticate' => 'Basic realm="Redmine API"')
                else
                  head(:forbidden)
                end
              end
              format.js   {head :unauthorized, 'WWW-Authenticate' => 'Basic realm="Redmine API"'}
              format.any  {head :unauthorized}
            end
            return false
          end
          true
        end
      end
    end
  end
end
