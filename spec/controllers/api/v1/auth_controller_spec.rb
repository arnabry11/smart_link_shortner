require 'rails_helper'

RSpec.describe Api::V1::AuthController, type: :controller do
  let(:valid_user_params) do
    {
      user: {
        email: 'test@example.com',
        password: 'password123',
        first_name: 'John',
        last_name: 'Doe'
      }
    }
  end

  let(:login_params) do
    {
      email: 'test@example.com',
      password: 'password123'
    }
  end

  describe 'POST #register' do
    before do
      allow(Warden::JWTAuth::UserEncoder).to receive(:new).and_return(
        double(call: [ 'mocked-jwt-token' ])
      )
    end

    context 'with valid parameters' do
      it 'creates a new user' do
        expect {
          post :register, params: valid_user_params
        }.to change(User, :count).by(1)
      end

      it 'returns user data and token' do
        post :register, params: valid_user_params

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)

        expect(json_response['user']).to include(
          'email' => 'test@example.com',
          'first_name' => 'John',
          'last_name' => 'Doe'
        )
        expect(json_response['token']).to eq('mocked-jwt-token')
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors for missing email' do
        invalid_params = valid_user_params.deep_merge(user: { email: nil })

        post :register, params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Email can't be blank")
      end

      it 'returns validation errors for duplicate email' do
        create(:user, email: 'test@example.com')

        post :register, params: valid_user_params

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Email has already been taken')
      end

      it 'returns validation errors for short password' do
        invalid_params = valid_user_params.deep_merge(user: { password: '123' })

        post :register, params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Password is too short (minimum is 6 characters)')
      end
    end
  end

  describe 'POST #login' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns user data and token' do
        allow(Warden::JWTAuth::UserEncoder).to receive(:new).and_return(
          double(call: [ 'mocked-jwt-token' ])
        )

        post :login, params: login_params

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['user']).to include(
          'email' => 'test@example.com',
          'first_name' => 'John',
          'last_name' => 'Doe'
        )
        expect(json_response['token']).to eq('mocked-jwt-token')
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized for wrong password' do
        invalid_params = login_params.merge(password: 'wrongpassword')

        post :login, params: invalid_params

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'returns unauthorized for non-existent email' do
        invalid_params = login_params.merge(email: 'nonexistent@example.com')

        post :login, params: invalid_params

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid email or password')
      end
    end
  end

  describe 'DELETE #logout' do
    let(:user) { create(:user) }

    context 'with authenticated user' do
      before do
        # Mock warden authentication by setting request environment
        request.env['warden'] = double(user: user)
      end

      it 'revokes user tokens' do
        expect {
          delete :logout
        }.to change(user, :token_version).from(1).to(2)
      end

      it 'returns success message' do
        delete :logout

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Logged out successfully')
      end
    end

    context 'without authenticated user' do
      before do
        request.env['warden'] = double(user: nil)
      end

      it 'returns unauthorized' do
        delete :logout

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Not authenticated')
      end
    end
  end

  describe 'POST #forgot_password' do
    context 'with existing user' do
      let!(:user) { create(:user, email: 'test@example.com') }

      it 'generates reset token' do
        expect {
          post :forgot_password, params: { email: 'test@example.com' }
        }.to change { user.reload.reset_password_token }.from(nil)
      end

      it 'sends reset password email' do
        expect {
          post :forgot_password, params: { email: 'test@example.com' }
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with('PasswordResetMailer', 'reset_password', 'deliver_now', { params: { user: user }, args: [] })
      end

      it 'returns success message' do
        post :forgot_password, params: { email: 'test@example.com' }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Password reset instructions sent to your email')
      end
    end

    context 'with non-existent user' do
      it 'does not generate reset token' do
        expect {
          post :forgot_password, params: { email: 'nonexistent@example.com' }
        }.not_to change(User, :count)
      end

      it 'returns generic success message for security' do
        post :forgot_password, params: { email: 'nonexistent@example.com' }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to include('If an account with that email exists')
      end
    end
  end

  describe 'POST #reset_password' do
    let!(:user) { create(:user, :with_reset_password_token) }
    let(:valid_reset_params) do
      {
        token: user.reset_password_token,
        password: 'newpassword123'
      }
    end

    context 'with valid reset token' do
      it 'updates the password' do
        post :reset_password, params: valid_reset_params

        user.reload
        expect(user.authenticate('newpassword123')).to eq(user)
      end

      it 'clears the reset token' do
        post :reset_password, params: valid_reset_params

        user.reload
        expect(user.reset_password_token).to be_nil
        expect(user.reset_password_sent_at).to be_nil
      end

      it 'returns success message' do
        post :reset_password, params: valid_reset_params

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Password reset successfully')
      end
    end

    context 'with expired reset token' do
      let!(:user) { create(:user, :with_expired_reset_token) }

      it 'returns unprocessable entity' do
        post :reset_password, params: { token: user.reset_password_token, password: 'newpassword123' }

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid or expired reset token')
      end

      it 'does not update password' do
        expect {
          post :reset_password, params: { token: user.reset_password_token, password: 'newpassword123' }
        }.not_to change { user.reload.password_digest }
      end
    end

    context 'with invalid token' do
      it 'returns unprocessable entity' do
        post :reset_password, params: { token: 'invalid-token', password: 'newpassword123' }

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid or expired reset token')
      end
    end

    context 'with invalid password' do
      it 'returns validation errors' do
        invalid_params = valid_reset_params.merge(password: '123')

        post :reset_password, params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Password is too short (minimum is 6 characters)')
      end
    end
  end
end
