# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  created_at             :datetime         not null
#  email                  :string
#  first_name             :string
#  last_name              :string
#  password_digest        :string
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  token_version          :integer          default(1), not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_token_version         (token_version)
#

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    first_name { "John" }
    last_name { "Doe" }
    token_version { 1 }

    trait :with_reset_password_token do
      reset_password_token { SecureRandom.urlsafe_base64 }
      reset_password_sent_at { 1.hour.ago }
    end

    trait :with_expired_reset_token do
      reset_password_token { SecureRandom.urlsafe_base64 }
      reset_password_sent_at { 3.hours.ago }
    end
  end
end
