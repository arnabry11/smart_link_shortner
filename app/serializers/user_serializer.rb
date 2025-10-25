class UserSerializer
  include Alba::Resource

  attributes :id, :email, :created_at, :updated_at

  # Optional: Transform timestamps to ISO 8601 format
  attribute :created_at do |user|
    user.created_at.iso8601
  end

  attribute :updated_at do |user|
    user.updated_at.iso8601
  end
end
