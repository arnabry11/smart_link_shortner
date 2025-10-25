module Api
  module V1
    class AuthController < ApplicationController
      before_action :authenticate_user!, only: [ :logout ]

      # POST /api/v1/auth/register
      def register
        user = User.new(register_params)
        if user.save
          token = Warden::JWTAuth::UserEncoder.new.call(user, :default, nil).first
          render json: {
            user: {
              id: user.id,
              email: user.email,
              first_name: user.first_name,
              last_name: user.last_name
            },
            token: token
          }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_content
        end
      end

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: params[:email]&.downcase)
        if user&.authenticate(params[:password])
          token = Warden::JWTAuth::UserEncoder.new.call(user, :default, nil).first
          render json: {
            user: {
              id: user.id,
              email: user.email,
              first_name: user.first_name,
              last_name: user.last_name
            },
            token: token
          }, status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      # DELETE /api/v1/auth/logout
      def logout
        current_user.revoke_all_tokens!
        render json: { message: "Logged out successfully" }, status: :ok
      end

      # POST /api/v1/auth/forgot_password
      def forgot_password
        user = User.find_by(email: params[:email]&.downcase)
        if user
          user.generate_reset_password_token!
          PasswordResetMailer.with(user: user).reset_password.deliver_later
          render json: { message: "Password reset instructions sent to your email" }, status: :ok
        else
          # Don't reveal if email exists or not for security
          render json: { message: "If an account with that email exists, password reset instructions have been sent" }, status: :ok
        end
      end

      # POST /api/v1/auth/reset_password
      def reset_password
        user = User.find_by(reset_password_token: params[:token])
        if user&.password_reset_token_valid?
          if user.update(password: params[:password])
            user.clear_reset_password_token!
            render json: { message: "Password reset successfully" }, status: :ok
          else
            render json: { errors: user.errors.full_messages }, status: :unprocessable_content
          end
        else
          render json: { error: "Invalid or expired reset token" }, status: :unprocessable_content
        end
      end

      private

      def register_params
        params.require(:user).permit(:email, :password, :first_name, :last_name)
      end
    end
  end
end
