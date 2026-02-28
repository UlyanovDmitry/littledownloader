# frozen_string_literal: true

class TelegramUpdateJob < ApplicationJob
  queue_as :default

  def perform(update)
    tg_update = Telegram::Types::UpdateFullData.new(update)

    return if tg_update.message.nil?
    chat_id = tg_update.message.chat.id

    return if chat_id.blank?
    msg = tg_update.message

    handler_klass = "Telegram::Handlers::#{msg.type.to_s.underscore.camelize}Handler".safe_constantize
    Rails.logger.info("[TelegramUpdateJob] Processing msg##{msg.type} with handler #{handler_klass}")
    return unless handler_klass.present?

    I18n.with_locale(fetch_locale(msg.user)) do
      with_db_user(msg.user) do |user|
        if user.allowed?
          handler_klass.call(chat_id, user, tg_update)
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

  def with_db_user(tg_user)
    return if tg_user&.id.blank?

    db_user = User.find_or_create_by!(telegram_user_id: tg_user.id) do |user|
      user.first_name = tg_user.first_name
      user.last_name = tg_user.last_name
      user.username = tg_user.username
    end

    yield(db_user) if block_given?
  end
end
