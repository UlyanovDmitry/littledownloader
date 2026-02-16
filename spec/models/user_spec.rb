require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { described_class.new(user_params) }

  describe "validations" do
    let(:user_params) { { telegram_user_id: 123456789, username: "testuser" } }

    it { is_expected.to be_valid }

    context 'when telegram_user_id are not present' do
      let(:user_params) { { username: "testuser" } }

      it 'is invalid' do
        expect(user).not_to be_valid
        expect(user.errors[:telegram_user_id]).to include("can't be blank")
      end
    end

    context 'when username are not present' do
      let(:user_params) { { telegram_user_id: 123456789 } }

      it 'is invalid' do
        expect(user).not_to be_valid
        expect(user.errors[:username]).to include("can't be blank")
      end
    end
  end
end
