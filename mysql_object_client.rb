#!/usr/bin/env ruby
require 'aws-sdk-s3'
require 'mysql'

# NOTE necessary environment variable:
# DB_HOST = <host_name>
# DB_PASSWD = <password>
# https://nopaste2.linecorp.com/entry/d9b63212-ff0b-432e-aca4-3403da65c9c8

Endpoint = 'https://line-objects-dev.com'

class MysqlObjectClient
    def initialize()
      host = ENV['DB_HOST'];
      passwd = ENV['DB_PASSWD'];
      @con = Mysql.new(host, 'admin', passwd, 'line_tic_hackathon', 20306)
    end

    def put_object(data, name)
        now = Time.now.to_i;
        @con.query("INSERT INTO cartridge(name, data, created_on) VALUES('#{name}', '#{data}', #{now})")
    end

    def get_object(name)
        res = @con.query("SELECT data FROM cartridge WHERE name = '#{name}'")
        puts res.fetch_row
    end
    def delete_object(name)
        res = @con.query("DELETE FROM cartridge WHERE name = '#{name}'")
    end

    def close()
        @con.close
    end
end

# TEST
# begin
#     client = MysqlObjectClient.new()
#     client.put_object('this is some data', 'miaou')
#     puts client.get_object('miaou')
#     client.delete_object('miaou')
#
# rescue Mysql::Error => e
#     puts e.errno
#     puts e.error
#
# ensure
#     client.close
# end
