class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  validates :first_name, presence: true
  validates :last_name, presence: true

  before_validation :downcase_email

  # JWT payload for warden-jwt_auth
  def jwt_payload
    {
      user_id: id,
      email: email,
      token_version: token_version,
      exp: 24.hours.from_now.to_i
    }
  end

  # JWT subject for warden-jwt_auth
  def jwt_subject
    id.to_s
  end

  # Revoke all tokens by incrementing token version
  def revoke_all_tokens!
    update!(token_version: token_version + 1)
  end

  # Generate password reset token
  def generate_reset_password_token!
    self.reset_password_token = SecureRandom.urlsafe_base64
    self.reset_password_sent_at = Time.current
    save!
  end

  # Check if password reset token is valid
  def password_reset_token_valid?
    reset_password_token.present? &&
    reset_password_sent_at.present? &&
    reset_password_sent_at > 2.hours.ago
  end

  # Clear password reset token
  def clear_reset_password_token!
    update!(
      reset_password_token: nil,
      reset_password_sent_at: nil
    )
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
