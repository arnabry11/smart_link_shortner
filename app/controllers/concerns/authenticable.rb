module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  def current_user
    @current_user
  end

  private

  def authenticate_user!
    token = extract_token_from_header

    if token
      begin
        payload = Warden::JWTAuth::TokenDecoder.new.call(token)
        @current_user = User.find_by(id: payload["user_id"])

        unless @current_user
          render json: { error: "Invalid token" }, status: :unauthorized
          return
        end

        # Check if token is expired
        if payload["exp"] && Time.at(payload["exp"]) < Time.current
          render json: { error: "Token revoked" }, status: :unauthorized
          return
        end

        # Check if token version matches
        if payload["token_version"] != @current_user.token_version
          render json: { error: "Token revoked" }, status: :unauthorized
          nil
        end

      rescue JWT::DecodeError, JWT::ExpiredSignature
        render json: { error: "Token revoked" }, status: :unauthorized
      end
    else
      render json: { error: "Missing authorization token" }, status: :unauthorized
    end
  end

  def extract_token_from_header
    header = request.headers["Authorization"]
    return nil unless header&.start_with?("Bearer ")
    header.split(" ", 2)&.last
  end
end
