# http://www.flaviogambardella.com/ruby-on-rails/configure-rails-to-use-mongodb-without-mongomapper/
class MongoConfig
  class << self
    attr_accessor :connection
  end
end

connection = Mongo::Connection.new(ENV['MONGO_HOST'], ENV['MONGO_PORT'])
MongoConfig.connection = connection
