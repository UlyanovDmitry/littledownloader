class Telegram::WebhooksController < ApplicationController
  before_action :verify_secret!

  def handler
    update_attributes = JSON.parse(request.raw_post)
    cache_key = ['telegram_message_update', update_attributes['update_id']]

    Rails.cache.fetch(cache_key, expires_in: 20.seconds) do
      TelegramUpdateJob.perform_later(update_attributes)
      true
    end
    head :ok
  rescue JSON::ParserError
    head :bad_request
  end

  private

  def webhook_header_token
    @webhook_header_token ||= ENV.fetch('TELEGRAM_WEBHOOK_HEADER_TOKEN', '').to_s
  end

  def verify_secret!
    got = request.headers['X-Telegram-Bot-Api-Secret-Token'].to_s
    raise ArgumentError, 'X-Telegram-Bot-Api-Secret-Token header is missing' if got.blank?
    head :unauthorized unless ActiveSupport::SecurityUtils.secure_compare(got, webhook_header_token)
  end
end
