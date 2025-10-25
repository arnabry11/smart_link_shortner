# == Schema Information
#
# Table name: jwt_blacklists
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  exp        :datetime
#  jti        :string
#  updated_at :datetime         not null
#
# Indexes
#
#  index_jwt_blacklists_on_jti  (jti)
#

FactoryBot.define do
  factory :jwt_blacklist do
    jti { "MyString" }
    exp { "2025-10-25 13:03:45" }
  end
end
