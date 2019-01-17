# frozen_string_literal: true

require 'line/bot'
require 'open-uri'

class LineController < ApplicationController
  def webhook
    client = initClient

    reply_token = params['events'][0]['replyToken']
    message = params['events'][0]['message']['text']

    response = handleMessageResponse(message)

    client.reply_message(reply_token, response)

    head :ok
  end

  private

  def initClient
    # save client setup in session rather than reset it in every request
    Line::Bot::Client.new do |config|
      config.channel_secret = ENV['CHANNEL_SECRET']
      config.channel_token = ENV['CHANNEL_ACCESS_TOKEN']
    end
  end

  def handleMessageResponse(message)
    response = {
      type: 'text',
      text: "請輸入：(法典)(空格)(條號)\n目前支援：憲法、民法、刑法"
    }

    if /^[憲|民|刑]法 [0-9]+/.match?(message)
      message = message.split(' ')
      law_content = getLawContent(message[0], message[1])

      response[:text] = "#{message[0]} 第 #{message[1]} 條\n#{law_content}"
    end

    response
  end

  def getLawContent(_codex, num)
    case _codex
    when '憲法' then pcode = 'A0000001'
    when '民法' then pcode = 'B0000001'
    when '刑法' then pcode = 'C0000001'
    end

    response = open("https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=#{pcode}",
                    'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36')
    law_page = Nokogiri::HTML(response, nil, 'UTF-8')

    target_law = law_page.xpath("//div[@class='col-no']/a[text()='第 #{num} 條']/parent::*/following-sibling::div[contains(@class,col-data)]").map(&:inner_text)

    target_law = target_law[0].split('。').join("。\n") + '。'

    target_law || '查無此條號'
  end
end
