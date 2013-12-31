# Ansible managed: /home/greg/repos/dota2rails/ansible/roles/app/templates/mongo.rb.j2 modified on 2013-12-20 21:51:31 by greg on ubuntu
# http://www.flaviogambardella.com/ruby-on-rails/configure-rails-to-use-mongodb-without-mongomapper/
class MongoConfig
  class << self
    attr_accessor :connection
  end
end

connection = Mongo::Connection.new("localhost", 27017)
MongoConfig.connection = connection
