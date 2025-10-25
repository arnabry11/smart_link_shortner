# Smart Link Shortener

A Rails application for shortening URLs with smart features and JWT-based authentication.

## Development Setup

### For Developers (Recommended)

Developers should use standard Rails commands for development. This gives you full control and faster development experience.

1. **Prerequisites:**
   - Ruby 3.4.7 (check `.ruby-version`)
   - PostgreSQL (running locally)
   - Redis (running locally)

2. **Install dependencies:**
   ```bash
   bundle install
   ```

3. **Setup database:**
   ```bash
   rails db:create
   rails db:migrate
   ```

4. **Setup Git hooks (recommended):**
   ```bash
   ./bin/setup-hooks
   ```
   This installs quality assurance hooks that automatically run:

   **Pre-commit hooks (via [pre-commit](https://pre-commit.com)):**
   - **trailing-whitespace** - Removes trailing whitespace from lines
   - **end-of-file-fixer** - Ensures files end with exactly one newline
   - **rubocop** - Runs RuboCop code quality checks
   - **rspec** - Runs RSpec tests on changed files

   **Pre-push hooks:**
   - **Brakeman** - Security vulnerability scanner
   - **RuboCop** - Full RuboCop analysis (all files)
   - **RSpec** - Full test suite

5. **Start the server:**
   ```bash
   rails server
   ```

6. **Common development commands:**
   ```bash
   rails console          # Start Rails console
   rails db:migrate       # Run migrations
   rails db:rollback      # Rollback migrations
   rails routes           # View all routes
   rails generate         # Generate models/controllers/etc
   bundle exec rspec      # Run tests
   bundle exec rubocop    # Run code quality checks
   ```

### Docker Compose (QA/Testing Only)

Docker Compose is provided for **QA and testing purposes only**. It allows quick environment setup for testing without affecting your local development environment.

```bash
# Start QA environment
docker-compose up --build

# Run Rails commands in Docker
docker-compose exec app rails db:migrate
docker-compose exec app rails console

# Stop environment
docker-compose down
```

**Note:** Docker setup includes PostgreSQL and Redis containers for isolated testing.

## Authentication System

This application uses JWT (JSON Web Tokens) with Warden for authentication. All authentication endpoints are under the `/api/v1/auth` namespace.

### JWT Features

- **Token-based authentication** - No sessions required
- **Token versioning** - Supports immediate token revocation
- **24-hour expiration** - Tokens automatically expire
- **Secure revocation** - Logout invalidates all user tokens

### Authentication Endpoints

- **POST `/api/v1/auth/register`** - Creates new user account and returns JWT token
- **POST `/api/v1/auth/login`** - Validates credentials and returns JWT token
- **DELETE `/api/v1/auth/logout`** - Revokes all user's tokens (token versioning)
- **POST `/api/v1/auth/forgot_password`** - Sends password reset email with secure token
- **POST `/api/v1/auth/reset_password`** - Resets password using reset token

### Authentication Business Logic

**🔐 JWT Token Management:**
- Tokens include user ID, email, token version, and 24-hour expiration
- All requests require `Authorization: Bearer <token>` header for protected endpoints
- Tokens are validated on every request using Warden middleware

**🚪 Token Revocation Strategy:**
- Uses **token versioning** instead of blacklists for better performance
- Each user has a `token_version` field that increments on logout
- Old tokens become invalid immediately when user logs out
- No database storage needed for revoked tokens

**📧 Password Reset Flow:**
- Generates secure URL-safe reset tokens (stored in database)
- Tokens expire after 2 hours for security
- Email contains clickable reset link with token
- Reset endpoint validates token before allowing password change

**🛡️ Security Features:**
- Passwords hashed with bcrypt (secure_password)
- Email uniqueness validation
- Token version validation on every request
- Secure random token generation for password resets
- Input validation and sanitization

**🔄 Multi-Session Support:**
- Users can have multiple concurrent sessions
- Logout revokes ALL sessions simultaneously
- Each device/app gets its own token but shares revocation

### Protecting Controllers

Include the `Authenticable` concern to require authentication:

```ruby
class Api::V1::ProtectedController < ApplicationController
  include Authenticable

  def index
    # @current_user available here
    render json: { data: @current_user }
  end
end
```

## Testing

```bash
# Run all tests
bundle exec rspec

# Run with coverage
COVERAGE=true bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb
```

## Code Quality

```bash
# Run all quality checks
bundle exec rubocop
bundle exec rubocop -a  # Auto-fix issues

# Security audit
bundle exec brakeman

# Run all checks
bundle exec rails_best_practices

# Pre-commit hooks (formatting and style)
pre-commit run --all-files  # Run all hooks on all files
pre-commit run trailing-whitespace --all-files  # Run specific hook
pre-commit run rubocop --all-files  # Run RuboCop on all files
```

## Deployment

This application uses Kamal for deployment. See `config/deploy.yml` for configuration.

```bash
# Deploy to production
kamal deploy
```

## Environment Variables

Copy `env.example` to `.env` and configure:

```bash
cp env.example .env
```

Key variables:
- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string
- `FRONTEND_URL` - Frontend URL for password reset links

# Test comment
