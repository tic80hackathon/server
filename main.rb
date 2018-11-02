require "sinatra"
require "line/bot"
require "base64"
require "./text_message_handler"

require "sinatra/reloader" if development?
require "active_record"

configure :development, :test do
  ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
end
ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])

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
  if params[:up]
    erb :upload
  else
    erb :liff
  end
end

post '/upload' do
  tic =
    if !params[:file].blank?
      params[:file][:tempfile].read
    else
      Base64.decode64(params[:file_base64])
    end
  # TODO: handle uploading name and description.
  name = params[:name]
  desc = params[:description]
  user_id = params[:user_id]
  display_name = params[:display_name]
  cartridge = CartridgeDAO.create(
    tic,
    name,
    desc,
    user_id,
    display_name
  )
  cartridge.url
end

get '/tic' do
    id = params[:id]
    c = CartridgeDAO.get_by_id(id)
    content_type 'application/octet-stream'
    c.tic
end

# NOTE ONLY for testing
require './cartridge_dao'
require 'json'
get '/create' do
    CartridgeDAO.create(tic: 'data' + rand(100000000).to_s, name: 'cartridge_' + rand(100000).to_s, description: 'This is cartridge XXXX')
end

get '/latest_cartridges' do
    CartridgeDAO.latests(10).to_json
end

get '/tic_data' do
    list = CartridgeDAO.latests(2)
    list[0].tic
end

get '/upload_page' do
  erb :upload
end
