require File.expand_path '../spec_helper.rb',  __FILE__
require 'base64'

describe "TIC-80 LIFF server" do
  it "should allow accessing the home page" do
    get '/'
    expect(last_response).to be_ok
  end

  it "should upload a cartridge file" do
    post '/upload', file: Rack::Test::UploadedFile.new('./spec/sample.tic', 'application/octet-stream')
    expect(last_response).to be_ok
  end

  it "should upload a cartridge file by base64" do
    post '/upload', file_base64: Base64.encode64(File.read('./spec/sample.tic'))
    expect(last_response).to be_ok
  end

end
