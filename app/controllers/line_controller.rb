# frozen_string_literal: true

require 'line/bot'
require 'open-uri'

class LineController < ApplicationController
  def webhook
    client = Line::Bot::Client.new do |config|
      config.channel_secret = ENV['CHANNEL_SECRET']
      config.channel_token = ENV['CHANNEL_ACCESS_TOKEN']
    end

    reply_token = params['events'][0]['replyToken']
    message = params['events'][0]['message']['text']

    response = nil

    if message == '給點活路'
      gallery = getGalleries.sample

      text = {
        type: 'text',
        text: gallery[0]
      }
      image = {
        type: 'image',
        originalContentUrl: gallery[2],
        previewImageUrl: gallery[2]
      }

      client.reply_message(reply_token, [text, image])
    end

    response = {
      type: 'text',
      text: message
    }

    client.reply_message(reply_token, response)

    head :ok
  end

  private

  def getGalleries
    response = open('https://e-hentai.org/',
                    'Host' => 'e-hentai.org',
                    'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36',
                    'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
                    'Cookie' => ENV['HENTAI_COOKIE'])

    html = Nokogiri::HTML(response, nil, 'UTF-8')

    titles = html.xpath('//div[@class="id2"]/a/text()').map(&:inner_text)
    links = html.xpath('//div[@class="id2"]/a/@href').map(&:inner_text)
    thumbnail = html.xpath('//div[@class="id3"]/a/img/@src').map(&:inner_text)

    titles.zip(links, thumbnail)
  end
end
