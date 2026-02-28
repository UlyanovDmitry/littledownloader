# frozen_string_literal: true

require 'net/http'
require 'json'

class TelegramClient
  API = 'https://api.telegram.org'
  class ResponseError < StandardError
    attr_reader :code
    def initialize(msg, code=nil)
      super(msg)
      @code = code
    end
  end

  def self.send_message(chat_id:, text:)
    token = ENV.fetch('TELEGRAM_TOKEN')
    uri = URI("#{API}/bot#{token}/sendMessage")

    body = { chat_id: chat_id, text: text }

    Net::HTTP.post(uri, body.to_json, 'Content-Type' => 'application/json')
  end

  def self.get_file_path(file_id)
    token = ENV.fetch('TELEGRAM_TOKEN')
    uri = URI("#{API}/bot#{token}/getFile?file_id=#{file_id}")

    response = Net::HTTP.get(uri)
    json = JSON.parse(response)

    raise ResponseError.new(json['description'], json['error_code']) unless json['ok']

    json.dig('result', 'file_path')
  end
end
