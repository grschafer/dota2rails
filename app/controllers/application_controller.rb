class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def db
    MongoConfig.connection.db(ENV['DB_NAME'])
  end
  def match_db
    db.collection(ENV['MATCH_COL'])
  end
  def league_db
    db.collection(ENV['LEAGUE_COL'])
  end
  def errorgame_db
    db.collection(ENV['ERRORGAME_COL'])
  end
  def userupload_db
    db.collection(ENV['USERUPLOAD_COL'])
  end

end
