require "active_record"

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

class Cartridge < ActiveRecord::Base
    def url
        'line://app/1618905586-vzX2N2jL?id=' + id.to_s
    end
end

class CartridgeDAO
    def self.create(tic, name = random_name, description = '...')
      Cartridge.create(tic: tic, name: name, description: description)
    end

    def self.get_by_id(id)
        Cartridge.limit(1).select('*')[0]
    end

    def self.latests(limit = 10)
        Cartridge.limit(limit).order(updated_at: :desc).select('*')
    end

    def self.random_name
        'cartridge_' + rand(10000).to_s
    end
end
