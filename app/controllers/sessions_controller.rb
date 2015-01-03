class SessionsController < ApplicationController

  def create
    session[:credentials] = env["omniauth.auth"]["credentials"]
    binding.pry
    # user = User.from_omniauth(env["omniauth.auth"])
    # session[:user_id] = user.id
    redirect_to '/messages/new'
  end

end
