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

class JwtBlacklist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  self.table_name = :jwt_blacklists
end
