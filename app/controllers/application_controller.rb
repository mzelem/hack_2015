class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def current_user
    @current_user ||= if session[:user_id].present?
                        User.find(session[:user_id])
                      elsif request.path_parameters[:format] == 'json'
                        User.order('updated_at desc').first
                      else
                        nil
                      end
  end

  def authorize_user
    
      session["credentials"] = {"token"=>"TIVXJBRUXxwf7RTe7argow2c4Qbjb4xp", "refresh_token"=>"MStMWsDVd2ydIXaNMx3wAiXqfFpwarCm", "expires_at"=>1420425344, "expires"=>true}
    redirect_to login_path unless current_user.present?
  end
end
