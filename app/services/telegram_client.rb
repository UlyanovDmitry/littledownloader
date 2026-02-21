# frozen_string_literal: true

require 'net/http'
require 'json'

class TelegramClient
  API = 'https://api.telegram.org'

  def self.send_message(chat_id:, text:)
    token = ENV.fetch('TELEGRAM_TOKEN')
    uri = URI("#{API}/bot#{token}/sendMessage")

    body = { chat_id: chat_id, text: text }

    Net::HTTP.post(uri, body.to_json, 'Content-Type' => 'application/json')
  end
end
