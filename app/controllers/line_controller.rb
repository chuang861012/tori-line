# frozen_string_literal: true

require 'line/bot'

class LineController < ApplicationController
  def webhook
    client = Line::Bot::Client.new do |config|
      config.channel_secret = ENV['CHANNEL_SECRET']
      config.channel_token = ENV['CHANNEL_ACCESS_TOKEN']
    end

    reply_token = params['events'][0]['replyToken']
    message = params['events'][0]['message']['text']

    p message

    response = {
      type: 'text',
      text: message
    }

    client.reply_message(reply_token, response)

    head :ok
  end
end
