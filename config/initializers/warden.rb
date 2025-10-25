Rails.application.config.middleware.use Warden::Manager do |manager|
  manager.default_strategies :jwt
  manager.failure_app = ->(env) { [ 401, { "Content-Type" => "application/json" }, [ { error: "Unauthorized" }.to_json ] ] }
end

Warden::Strategies.add(:jwt) do
  def valid?
    env["HTTP_AUTHORIZATION"].present?
  end

  def authenticate!
    token = env["HTTP_AUTHORIZATION"].split(" ").last
    payload = Warden::JWTAuth::TokenDecoder.new.call(token)

    if payload
      user = User.find_by(id: payload["user_id"])
      if user && payload["token_version"] == user.token_version
        success!(user)
      else
        fail!("Token revoked")
      end
    end
  rescue JWT::DecodeError
    fail!("Invalid token")
  end
end

Warden::JWTAuth.configure do |config|
  config.secret = ENV["JWT_SECRET"]
  config.mappings = { default: ->(user) { user.jwt_payload } }
  config.dispatch_requests = [
    [ "POST", %r{^/api/v1/auth/login$} ],
    [ "POST", %r{^/api/v1/auth/register$} ],
    [ "POST", %r{^/api/v1/auth/forgot_password$} ],
    [ "POST", %r{^/api/v1/auth/reset_password$} ]
  ]
  config.revocation_requests = [
    [ "DELETE", %r{^/api/v1/auth/logout$} ]
  ]
end
