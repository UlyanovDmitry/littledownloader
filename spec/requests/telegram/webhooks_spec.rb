require "rails_helper"

RSpec.describe "Telegram::Webhooks", type: :request do
  let(:webhook_secret) { "test_secret_123" }
  let(:webhook_header_token) { "header_token_456" }

  before do
    stub_const("ENV", ENV.to_h.merge("TELEGRAM_WEBHOOK_HEADER_TOKEN" => webhook_header_token))
    stub_const("ENV", ENV.to_h.merge("TELEGRAM_WEBHOOK_SECRET" => webhook_secret))
  end

  describe "POST /telegram/webhook/:secret" do
    let(:headers) { { "X-Telegram-Bot-Api-Secret-Token" => webhook_header_token } }
    let(:params) { { update_id: 123, message: { text: "hello" } } }
    let(:url) { "/telegram/webhook/#{webhook_secret}" }

    before { post url, params: params.to_json, headers: headers }

    context "with valid secret and token" do
      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid secret" do
      let(:url) { "/telegram/webhook/wrong_secret" }

      it "returns unauthorized" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with invalid token" do
      let(:headers) { { "X-Telegram-Bot-Api-Secret-Token" => "wrong_token" } }

      it "returns unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "without token" do
      let(:headers) { {} }

      it "returns unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
