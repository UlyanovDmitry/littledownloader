module Downloads
  class Notifier
    def initialize(download)
      @download = download
    end

    def notify_success(filename)
      notify_chat(success_message(filename))
      notify_admins(admin_success_message(filename))
    end

    def notify_failure(error)
      notify_chat(failure_message(error))
      notify_admins(admin_failure_message(error.message))
    end

    private

    attr_reader :download

    def notify_chat(text)
      TelegramClient.send_message(chat_id: download.chat.telegram_chat_id, text: text)
    end

    def notify_admins(text)
      User.where(role: 'admin').where.not(id: download.user_id).find_each do |admin|
        TelegramClient.send_message(chat_id: admin.telegram_user_id, text: text)
      end
    end

    def success_message(filename)
      I18n.t('telegram.handlers.download.success', id: download.id, filename: filename)
    end

    def admin_success_message(filename)
      I18n.t(
        'telegram.handlers.download.admin_notification',
        id: download.id,
        filename: filename,
        username: download.user.username
      )
    end

    def failure_message(error)
      full_message_enabled = download.user.admin? || download.chat.with_admins?
        || error.is_a?(Downloads::LimitsChecker::LimitExceededError)
        || error.is_a?(Downloads::LimitsChecker::DiskSpaceError)

      key = full_message_enabled ? 'telegram.handlers.download.failed' : 'telegram.handlers.download.simple_failed'

      I18n.t(key, id: download.id, error: error.message)
    end

    def admin_failure_message(error)
      I18n.t(
        'telegram.handlers.download.admin_failed_notification',
        id: download.id,
        error: error,
        username: download.user.username
      )
    end
  end
end
