# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  respond_to :json

  # Include flash support for API responses
  include ActionController::Flash

  private

  def respond_with(resource, _opts = {})
    if resource && resource.persisted?
      render json: {
        status: { code: 200, message: "Logged in successfully." },
        data: UserSerializer.new(resource)
      }, status: :ok
    else
      render json: {
        error: "Invalid Email or password."
      }, status: :unauthorized
    end
  end

  def respond_to_on_destroy
    # For JWT authentication, logout succeeds if a valid token is provided
    # Invalid or missing tokens should still return an error
    if request.headers["Authorization"].present?
      render json: {
        status: 200,
        message: "Logged out successfully."
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
