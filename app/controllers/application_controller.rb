class ApplicationController < ActionController::Base
  before_filter :set_oauth_session
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

  def set_oauth_session
    session["credentials"] = {"token"=>"ymoy6tLDf0CM1XFjWFS2c31vBTL3WzVz",
                              "refresh_token"=>"gR7XYXm44sr4NwhPJSOzmO9vlzNppjA3",
                              "expires_at"=>1420576819,
                              "expires"=>true}

  end

  def authorize_user
    redirect_to login_path unless current_user.present?
  end
end
