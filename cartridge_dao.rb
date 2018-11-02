require "active_record"

configure :development, :test do
  ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
end
ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

class Cartridge < ActiveRecord::Base
    def url
        'www.example.com/' + name
    end
end

class CartridgeDAO
    def self.create(tic, name = random_name, description = '...')
      Cartridge.create(tic: tic, name: name, description: description)
    end

    def self.latests(limit = 10)
        Cartridge.limit(limit).order(updated_at: :desc).select('*')
    end

    def self.random_name
        'cartridge_' + rand(10000).to_s
    end
end
