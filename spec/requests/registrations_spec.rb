require 'rails_helper'

RSpec.describe "User Registrations API", type: :request do
  describe "POST /signup" do
    let(:valid_signup_params) do
      {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    let(:invalid_signup_params) do
      {
        user: {
          email: "",
          password: "pass",
          password_confirmation: "different"
        }
      }
    end

    context "with valid parameters" do
      it "creates a new user and returns success response" do
        expect {
          post "/signup", params: valid_signup_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key("status")
        expect(json_response["status"]["code"]).to eq(200)
        expect(json_response["status"]["message"]).to eq("Signed up successfully.")

        expect(json_response).to have_key("data")
        expect(json_response["data"]["email"]).to eq("newuser@example.com")
        expect(json_response["data"]).to have_key("id")
        expect(json_response["data"]).to have_key("created_at")
        expect(json_response["data"]).to have_key("updated_at")

        # Check that JWT token is included in response headers
        expect(response.headers).to have_key("Authorization")
      end
    end

    context "with invalid parameters" do
      it "returns validation errors" do
        expect {
          post "/signup", params: invalid_signup_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key("status")
        expect(json_response["status"]["code"]).to eq(422)
        expect(json_response["status"]["message"]).to include("User couldn't be created successfully")
      end
    end

    context "with duplicate email" do
      let!(:existing_user) { create(:user, email: "duplicate@example.com") }

      let(:duplicate_email_params) do
        {
          user: {
            email: "duplicate@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      it "returns validation error" do
        expect {
          post "/signup", params: duplicate_email_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)

        expect(json_response["status"]["message"]).to include("Email has already been taken")
      end
    end

    context "with missing parameters" do
      it "returns validation errors" do
        expect {
          post "/signup", params: {}
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)

        expect(json_response["status"]["code"]).to eq(422)
      end
    end
  end

  describe "DELETE /signup" do
    let!(:user) { create(:user) }
    let(:auth_token) do
      post "/login", params: { user: { email: user.email, password: "password123" } }
      response.headers["Authorization"]
    end

    context "when user is authenticated" do
      it "deletes the user account" do
        expect {
          delete "/signup", headers: { "Authorization" => auth_token }
        }.to change(User, :count).by(-1)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key("status")
        expect(json_response["status"]["code"]).to eq(200)
        expect(json_response["status"]["message"]).to eq("Account deleted successfully.")
      end
    end

    context "when user is not authenticated" do
      it "redirects to login" do
        expect {
          delete "/signup"
        }.not_to change(User, :count)

        expect(response).to have_http_status(:found) # 302 redirect
      end
    end
  end
end
