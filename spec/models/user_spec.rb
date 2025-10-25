require 'rails_helper'

RSpec.describe User do
  describe 'validations' do
    it 'validates presence of email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'validates presence of first_name' do
      user = build(:user, first_name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include("can't be blank")
    end

    it 'validates presence of last_name' do
      user = build(:user, last_name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:last_name]).to include("can't be blank")
    end

    it 'validates email uniqueness case insensitively' do
      existing_user = create(:user, email: 'test@example.com')
      new_user = build(:user, email: 'TEST@EXAMPLE.COM')
      expect(new_user).not_to be_valid
      expect(new_user.errors[:email]).to include('has already been taken')
    end

    it 'validates email format' do
      valid_user = build(:user, email: 'user@example.com')
      invalid_user = build(:user, email: 'invalid-email')

      expect(valid_user).to be_valid
      expect(invalid_user).not_to be_valid
    end

    it 'validates password length on create' do
      user = build(:user, password: '12345')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
    end
  end

  describe 'password authentication' do
    let(:user) { create(:user, password: 'password123') }

    it 'authenticates with correct password' do
      expect(user.authenticate('password123')).to eq(user)
    end

    it 'does not authenticate with incorrect password' do
      expect(user.authenticate('wrongpassword')).to be_falsey
    end
  end

  describe 'email normalization' do
    it 'downcases email before saving' do
      user = create(:user, email: 'USER@EXAMPLE.COM')
      expect(user.email).to eq('user@example.com')
    end
  end

  describe 'JWT payload' do
    let_it_be(:user) { create(:user) }

    it 'includes required fields' do
      payload = user.jwt_payload
      expect(payload).to include(:user_id, :email, :token_version, :exp)
      expect(payload[:user_id]).to eq(user.id)
      expect(payload[:email]).to eq(user.email)
      expect(payload[:token_version]).to eq(user.token_version)
      expect(payload[:exp]).to be > Time.current.to_i
    end

    it 'sets expiration to 24 hours from now' do
      payload = user.jwt_payload
      expected_exp = 24.hours.from_now.to_i
      expect(payload[:exp]).to be_within(60).of(expected_exp)
    end
  end

  describe 'token revocation' do
    let_it_be(:user, reload: true) { create(:user, token_version: 1) }

    it 'starts with token_version 1' do
      expect(user.token_version).to eq(1)
    end

    it 'increments token_version when revoked' do
      expect { user.revoke_all_tokens! }.to change(user, :token_version).from(1).to(2)
    end
  end

  describe 'password reset' do
    let_it_be(:user, reload: true) { create(:user) }

    describe '#generate_reset_password_token!' do
      it 'generates a reset token' do
        expect(user.reset_password_token).to be_nil
        user.generate_reset_password_token!
        expect(user.reset_password_token).to be_present
        expect(user.reset_password_sent_at).to be_present
      end

      it 'sets reset_password_sent_at to current time' do
        freeze_time do
          user.generate_reset_password_token!
          expect(user.reset_password_sent_at).to eq(Time.current)
        end
      end
    end

    describe '#password_reset_token_valid?' do
      context 'with valid token' do
        let(:user) { create(:user, :with_reset_password_token) }

        it 'returns true' do
          expect(user.password_reset_token_valid?).to be_truthy
        end
      end

      context 'with expired token' do
        let(:user) { create(:user, :with_expired_reset_token) }

        it 'returns false' do
          expect(user.password_reset_token_valid?).to be_falsey
        end
      end

      context 'without token' do
        it 'returns false' do
          expect(user.password_reset_token_valid?).to be_falsey
        end
      end
    end

    describe '#clear_reset_password_token!' do
      let(:user) { create(:user, :with_reset_password_token) }

      it 'clears the reset token and timestamp' do
        expect(user.reset_password_token).to be_present
        expect(user.reset_password_sent_at).to be_present

        user.clear_reset_password_token!

        expect(user.reset_password_token).to be_nil
        expect(user.reset_password_sent_at).to be_nil
      end
    end
  end

  describe 'has_secure_password' do
    it 'provides password authentication' do
      user = build(:user)
      expect(user).to respond_to(:authenticate)
    end

    it 'validates password presence on create' do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end
  end
end
