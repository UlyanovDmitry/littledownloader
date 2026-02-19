require "rails_helper"

RSpec.describe "Telegram::Webhooks", type: :request do
  let(:webhook_secret) { "test_secret_123" }
  let(:webhook_header_token) { "header_token_456" }

  before do
    allow(Rails.application.credentials).to receive(:dig).with(:telegram, :webhook_secret).and_return(webhook_secret)
    stub_const("ENV", ENV.to_h.merge("TELEGRAM_WEBHOOK_HEADER_TOKEN" => webhook_header_token))
  end

  describe "POST /telegram/webhook/:secret" do
    let(:headers) { { "X-Telegram-Bot-Api-Secret-Token" => webhook_header_token } }
    let(:url) { "/telegram/webhook/#{webhook_secret}" }

    before { post url, headers: headers }

    context "with valid secret and token" do
      it "returns http success" do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ "status" => "ok" })
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
        expect(JSON.parse(response.body)).to eq({ "error" => "unauthorized" })
      end
    end

    context "without token" do
      let(:headers) { {} }

      it "returns unauthorized" do
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ "error" => "unauthorized" })
      end
    end
  end
end
