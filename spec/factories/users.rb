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
