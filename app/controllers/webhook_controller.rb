require 'line/bot/client'

class WebhookController < ApplicationController
  protect_from_forgery except: :callback # CSRF対策無効化


  def callback
    unless is_validate_signature
      render :nothing => true, status: 470
    end

=begin
    json format
    {
      "result":[
        {
          "from":"u206d25c2ea6bd87c17655609a1c37cb8",
          "fromChannel":1341301815,
          "to":["u0cc15697597f61dd8b01cea8b027050e"],
          "toChannel":1441301333,
          "eventType":"138311609000106303",
          "id":"ABCDEF-12345678901",
          "content":{
            ...
          }
        }
      ]
    } 
=end

    result = params[:result][0]
    logger.info({from_line: result})
    text_message = result['content']['text']
    from_mid =result['content']['from']

    client = Line::Bot::Client.new do |config|
      config.channel_id     = ENV['LINE_CHANNEL_ID']
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_mid    = ENV['LINE_CHANNEL_MID']
      config.proxy          = ENV['LINE_OUTBOUND_PROXY']
    end
    res = client.send_text([from_mid], text_message)

    if res.status == 200
      logger.info({success: res})
    else
      logger.info({fail: res})
    end
    render :nothing => true, status: :ok
  end

  private
  # LINEからのアクセスか確認.
  # 認証に成功すればtrueを返す。
  # ref) https://developers.line.me/bot-api/getting-started-with-bot-api-trial#signature_validation
  def is_validate_signature
    signature = request.headers["X-LINE-ChannelSignature"]
    http_request_body = request.raw_post
    hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, ENV['LINE_CHANNEL_SECRET'], http_request_body)
    signature_answer = Base64.strict_encode64(hash)
    signature == signature_answer
  end
end
