# frozen_string_literal: true

class TelegramUpdateJob < ApplicationJob
  queue_as :default

  def perform(update)
    tg_update = Telegram::Types::UpdateFullData.new(update)

    msg = tg_update.message
    return if msg.nil?

    chat_id = msg.chat.id
    return if chat_id.blank?

    handler_klass = "Telegram::Handlers::#{msg.type.to_s.underscore.camelize}Handler".safe_constantize
    Rails.logger.info("[TelegramUpdateJob] Processing msg##{msg.type} with handler #{handler_klass}")
    return unless handler_klass.present?

    I18n.with_locale(fetch_locale(msg.user)) do
      with_db_object(msg.user, msg.chat) do |user, db_chat|
        if user.allowed?
          handler_klass.call(db_chat, user, tg_update)
        else
          TelegramClient.send_message(
            chat_id:,
            text: I18n.t('telegram.handlers.errors.not_allowed', telegram_id: user.telegram_user_id)
          )
        end
      end
    end
  end

  private

  def fetch_locale(user)
    return user&.language_code if I18n.available_locales.map(&:to_s).include?(user&.language_code.to_s)

    I18n.default_locale
  end

  def with_db_object(tg_user, tg_chat)
    return if tg_user&.id.blank?

    db_user = User.find_or_create_by!(telegram_user_id: tg_user.id) do |user|
      user.first_name = tg_user.first_name
      user.last_name = tg_user.last_name
      user.username = tg_user.username
    end
    db_chat = Chat.find_or_create_by!(telegram_chat_id: tg_chat.id) do |chat|
      chat.title = tg_chat.title
      chat.first_name = tg_chat.first_name
      chat.last_name = tg_chat.last_name
      chat.username = tg_chat.username
    end

    yield(db_user, db_chat) if block_given?
  end
end
