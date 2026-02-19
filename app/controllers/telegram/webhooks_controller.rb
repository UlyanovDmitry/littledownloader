class Telegram::WebhooksController < ApplicationController
  before_action :verify_secret!

  def handler
    render json: { status: "ok" }, status: :ok
  end

  private

  def webhook_header_token
    @webhook_header_token ||= ENV["TELEGRAM_WEBHOOK_HEADER_TOKEN"]
  end

  def verify_secret!
    got = request.headers["X-Telegram-Bot-Api-Secret-Token"].to_s
    head :unauthorized unless ActiveSupport::SecurityUtils.secure_compare(got, webhook_header_token)
  end
end
