require "sinatra"
require "active_record"
require "line/bot"
require "./text_message_handler"

require "sinatra/reloader" if development?

configure :development, :test do
  ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
end
ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

class Cartridge < ActiveRecord::Base

end

get '/' do
  'Hello World!'
end

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

def text_handler
    @text_handler ||= TextMessageHandler.new(client)
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
          text_handler.handle(event)
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      end
    end
  }

  "OK"
end

get '/liff' do
  erb :liff
end

post '/upload' do
  Cartridge.create(tic: params[:file][:tempfile].read)
  redirect '/upload'
end

get '/upload' do
  'Uploaded'
end
