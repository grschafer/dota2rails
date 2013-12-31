class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # cache the whole page in production
  # TODO: move to fragment caching now that there's user session
  if Rails.env.production?
    caches_page :index, :show
  end

  private

  def db
    MongoConfig.connection.db('alacrity').collection('matches')
  end

end
