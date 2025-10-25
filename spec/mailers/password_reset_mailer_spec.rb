require 'rails_helper'

RSpec.describe PasswordResetMailer, type: :mailer do
  describe '#reset_password' do
    let_it_be(:user) { create(:user, :with_reset_password_token) }
    let(:mail) { PasswordResetMailer.with(user: user).reset_password }

    it 'renders the headers' do
      expect(mail.subject).to eq('Reset your password')
      expect(mail.to).to eq([ user.email ])
      expect(mail.from).to eq([ 'from@example.com' ])
    end

    it 'includes user first name in the body' do
      expect(mail.html_part.body.to_s).to include(user.first_name)
      expect(mail.text_part.body.to_s).to include(user.first_name)
    end

    it 'includes reset password URL' do
      reset_url = "#{ENV.fetch('FRONTEND_URL', 'http://localhost:3000')}/reset-password?token=#{user.reset_password_token}"

      expect(mail.html_part.body.to_s).to include(reset_url)
      expect(mail.text_part.body.to_s).to include(reset_url)
    end

    it 'includes expiration notice' do
      expect(mail.html_part.body.to_s).to include('2 hours')
      expect(mail.text_part.body.to_s).to include('2 hours')
    end

    it 'includes security notice' do
      expect(mail.html_part.body.to_s).to include("didn't request this")
      expect(mail.text_part.body.to_s).to include("didn't request this")
    end

    it 'renders HTML and text parts' do
      expect(mail.html_part).to be_present
      expect(mail.text_part).to be_present
      expect(mail.html_part.content_type).to include('text/html')
      expect(mail.text_part.content_type).to include('text/plain')
    end
  end
end
