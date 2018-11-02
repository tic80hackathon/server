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
          altText: 'Carousel alt text',
          template: {
            type: 'carousel',
            columns: [
              {
                title: 'hoge',
                text: 'fuga',
                actions: [
                  { label: 'Go to line.me', type: 'uri', uri: 'https://line.me' },
                  { label: 'Send postback', type: 'postback', data: 'hello world' },
                  { label: 'Send message', type: 'message', text: 'This is message' }
                ]
              },
              {
                title: 'Datetime Picker',
                text: 'Please select a date, time or datetime',
                actions: [
                  {
                    type: 'datetimepicker',
                    label: "Datetime",
                    data: 'action=sel',
                    mode: 'datetime',
                    initial: '2017-06-18T06:15',
                    max: '2100-12-31T23:59',
                    min: '1900-01-01T00:00'
                  },
                  {
                    type: 'datetimepicker',
                    label: "Date",
                    data: 'action=sel&only=date',
                    mode: 'date',
                    initial: '2017-06-18',
                    max: '2100-12-31',
                    min: '1900-01-01'
                  },
                  {
                    type: 'datetimepicker',
                    label: "Time",
                    data: 'action=sel&only=time',
                    mode: 'time',
                    initial: '12:15',
                    max: '23:00',
                    min: '10:00'
                  }
                ]
              }
            ]
          }
        })
    end
end
