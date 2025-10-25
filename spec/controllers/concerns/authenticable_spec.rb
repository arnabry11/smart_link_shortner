require 'rails_helper'

class TestAuthenticableController < ApplicationController
  include Authenticable

  def index
    render json: { user_id: current_user.id }
  end
end

RSpec.describe Authenticable, type: :controller do
  controller TestAuthenticableController do
    def index
      render json: { user_id: current_user.id }
    end
  end

  let_it_be(:user, reload: true) { create(:user) }

  describe '#authenticate_user!' do
    context 'with valid JWT token' do
      let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :default, nil).first }
      let(:auth_header) { "Bearer #{token}" }

      before do
        request.headers['Authorization'] = auth_header
      end

      it 'sets current_user' do
        get :index
        expect(assigns(:current_user)).to eq(user)
      end

      it 'allows the request to proceed' do
        get :index
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['user_id']).to eq(user.id)
      end
    end

    context 'with revoked token (different token_version)' do
      let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :default, nil).first }

      before do
        request.headers['Authorization'] = "Bearer #{token}"
        user.revoke_all_tokens!
      end

      it 'returns unauthorized' do
        get :index
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Token revoked')
      end
    end

    context 'with expired token' do
      let(:expired_token) do
        # Create a token that expires immediately
        payload = user.jwt_payload.merge(exp: 1.hour.ago.to_i)
        JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
      end

      before do
        request.headers['Authorization'] = "Bearer #{expired_token}"
      end

      it 'returns unauthorized' do
        get :index
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Token revoked')
      end
    end

    context 'with malformed token' do
      before do
        request.headers['Authorization'] = 'Bearer invalid-token'
      end

      it 'returns unauthorized' do
        get :index
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Token revoked')
      end
    end

    context 'without authorization header' do
      it 'returns unauthorized' do
        get :index
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Missing authorization token')
      end
    end

    context 'with malformed authorization header' do
      before do
        request.headers['Authorization'] = 'InvalidFormat'
      end

      it 'returns unauthorized' do
        get :index
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Missing authorization token')
      end
    end
  end

  describe '#current_user' do
    it 'returns the authenticated user' do
      token = Warden::JWTAuth::UserEncoder.new.call(user, :default, nil).first
      request.headers['Authorization'] = "Bearer #{token}"

      get :index
      expect(controller.current_user).to eq(user)
    end

    it 'returns nil when not authenticated' do
      get :index
      expect(controller.current_user).to be_nil
    end
  end

  describe '#extract_token_from_header' do
    context 'with Bearer token' do
      it 'extracts the token' do
        request.headers['Authorization'] = 'Bearer abc123'
        expect(controller.send(:extract_token_from_header)).to eq('abc123')
      end
    end

    context 'without Bearer prefix' do
      it 'returns nil' do
        request.headers['Authorization'] = 'abc123'
        expect(controller.send(:extract_token_from_header)).to be_nil
      end
    end

    context 'without authorization header' do
      it 'returns nil' do
        expect(controller.send(:extract_token_from_header)).to be_nil
      end
    end
  end
end
