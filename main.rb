require "sinatra"
require "active_record"

require "sinatra/reloader" if development?

ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"] || "sqlite3:db/development.db")

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

class Cartridge < ActiveRecord::Base

end

get "/" do
  'Hello World!'
end
