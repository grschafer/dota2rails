class AuthController < ApplicationController
  # auth callback POST comes from Steam so we can't attach CSRF token
  skip_before_filter :verify_authenticity_token, :only => :auth_callback

  def auth_callback
    auth = request.env['omniauth.auth']
    session[:user] = { :nickname => auth.info['nickname'],
                       :image => auth.info['image'],
                       :uid => auth.uid }
    redirect_to root_url
  end

  def logout
    session.delete(:user)
    redirect_to root_url
  end
end
