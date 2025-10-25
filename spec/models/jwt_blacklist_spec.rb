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

require 'rails_helper'

RSpec.describe JwtBlacklist, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
