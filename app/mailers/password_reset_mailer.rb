class PasswordResetMailer < ApplicationMailer
  def reset_password
    @user = params[:user]
    @reset_url = "#{ENV.fetch('FRONTEND_URL', 'http://localhost:3000')}/reset-password?token=#{@user.reset_password_token}"

    mail(
      to: @user.email,
      subject: "Reset your password"
    )
  end
end
