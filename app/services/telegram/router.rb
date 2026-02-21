module Telegram
  class Router
    attr_reader :tg_update
    def self.call(update) = new(update).call

    def initialize(update)
      @tg_update = UpdateFullData.new update
    end

    def call
      chat_id = tg_update.chat.id

      return if chat_id.blank?
      msg = tg_update.message

      return Handlers::BotCommandHandler.call(chat_id, msg) if msg.command?
      return Handlers::TextHandler.call(chat_id, msg) if msg.text.present?

      nil
    end
  end
end
