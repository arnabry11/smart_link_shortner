require 'rails_helper'

RSpec.describe "Authentication API", type: :request do
  let(:user) { create(:user) }
  let(:valid_login_params) do
    {
      user: {
        email: user.email,
        password: "password123"
      }
    }
  end

  let(:invalid_login_params) do
    {
      user: {
        email: user.email,
        password: "wrongpassword"
      }
    }
  end

  describe "POST /login" do
    context "with valid credentials" do
      it "returns success response with user data and JWT token" do
        post "/login", params: valid_login_params

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key("status")
        expect(json_response["status"]["code"]).to eq(200)
        expect(json_response["status"]["message"]).to eq("Logged in successfully.")

        expect(json_response).to have_key("data")
        expect(json_response["data"]["email"]).to eq(user.email)
        expect(json_response["data"]).to have_key("id")
        expect(json_response["data"]).to have_key("created_at")
        expect(json_response["data"]).to have_key("updated_at")

        # Check that JWT token is included in response headers
        expect(response.headers).to have_key("Authorization")
        expect(response.headers["Authorization"]).to start_with("Bearer ")
      end
    end

    context "with invalid credentials" do
      it "returns error response" do
        post "/login", params: invalid_login_params

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key("error")
        expect(json_response["error"]).to eq("Invalid Email or password.")
      end
    end

    context "with missing parameters" do
      it "returns error response" do
        post "/login", params: {}

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key("error")
      end
    end
  end

  describe "DELETE /logout" do
    context "when user is logged in" do
      it "returns success response" do
        post "/login", params: valid_login_params
        auth_token = response.headers["Authorization"]

        delete "/logout", headers: { "Authorization" => auth_token }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response["status"]).to eq(200)
        expect(json_response["message"]).to eq("Logged out successfully.")
      end
    end

    context "when user is not logged in" do
      it "returns unauthorized error" do
        delete "/logout"

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)

        expect(json_response["status"]).to eq(401)
        expect(json_response["message"]).to eq("Couldn't find an active session.")
      end
    end
  end
end
