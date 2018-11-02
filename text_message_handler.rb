require "line/bot"
require './cartridge_dao'

class TextMessageHandler
    def initialize(client)
        @client = client
    end

    def handle(event)
        text = event.message['text']
        case text
        when 'latest'
            cartridges = CartridgeDAO.latests(10)
            if cartridges.length > 0
                latest_cartridges2(event, cartridges)
            else
                reply_text(event, 'No cartridges. Create one !')
            end
        else
            reply_text(event, "You said: `#{text}`")
        end
    end

    def reply_text(event, texts)
      texts = [texts] if texts.is_a?(String)
      @client.reply_message(
        event['replyToken'],
        texts.map { |text| {type: 'text', text: text} }
      )
    end

    def reply_content(event, messages)
      res = @client.reply_message(
        event['replyToken'],
        messages
      )
      puts res.read_body if res.code != 200
    end

    def latest_cartridges(event, cartridges)
        columns = cartridges.map do |c|
            {
              title: c.name,
              text: c.description,
              actions: [
                { label: 'Download game ', type: 'uri', uri: c.url },
              ]
            }
        end

        reply_content(event, {
          type: 'template',
          altText: 'List latest cartridges',
          template: {
            type: 'carousel',
            columns: columns
          }
        })
    end

    def latest_cartridges2(event, cartridges)
        reply_content(event, {
           type: 'template',
           altText: 'Image carousel alt text',
           template: {
             type: 'image_carousel',
             columns: [
               {
                 imageUrl: THUMBNAIL_URL,
                 action: { label: 'line.me', type: 'uri', uri: 'https://line.me' }
               },
               {
                 imageUrl: THUMBNAIL_URL,
                 action: { label: 'postback', type: 'postback', data: 'hello world' }
               },
               {
                 imageUrl: THUMBNAIL_URL,
                 action: { label: 'message', type: 'message', text: 'This is message' }
               },
               {
                 imageUrl: THUMBNAIL_URL,
                 action: {
                   type: 'datetimepicker',
                   label: "Datetime",
                   data: 'action=sel',
                   mode: 'datetime',
                   initial: '2017-06-18T06:15',
                   max: '2100-12-31T23:59',
                   min: '1900-01-01T00:00'
                 }
               }
             ]
           }
         })
    end
end
