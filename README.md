# Smart Link Shortener

A Rails application for shortening URLs with smart features and JWT-based authentication.

## Development Setup

### For Developers (Standard Rails Setup)

**Docker is intended for QA/testing purposes only.** Developers should use standard Rails development practices for better debugging, faster iteration, and IDE integration.

#### Prerequisites
- Ruby 3.4.7 (use a version manager like `rbenv` or `asdf`)
- PostgreSQL 13+
- Redis 6+
- Git

#### Initial Setup for New Developers

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd smart_link_shortner
   ```

2. **Install Ruby dependencies:**
   ```bash
   bundle install
   ```

3. **Setup environment variables:**
   ```bash
   cp env.example .env
   # Edit .env with your local configuration
   ```

4. **Setup the database:**
   ```bash
   ./bin/rails db:create
   ./bin/rails db:migrate
   ./bin/rails db:seed  # if seeds are available
   ```

5. **Start the development server:**
   ```bash
   ./bin/rails server
   ```

6. **Access the application:**
   - Rails app: http://localhost:3000
   - Health check: http://localhost:3000/up

#### Development Commands

```bash
# Run the Rails console
./bin/rails console

# Run database migrations
./bin/rails db:migrate

# Run RSpec tests
./bin/rails spec

# Run linters and code quality checks
bundle exec rubocop
bundle exec reek
bundle exec brakeman

# Annotate models with schema information
bundle exec annotate

# Generate new models/controllers/etc.
./bin/rails generate model User email:string
./bin/rails generate controller Users
```

### For QA/Testers (Docker Setup)

Use Docker for isolated testing environments or when you don't want to install Ruby/PostgreSQL/Redis locally.

#### Prerequisites
- Docker and Docker Compose

#### Quick Start
```bash
docker-compose up --build
```

#### Access Points
- Rails app: http://localhost:3000
- PostgreSQL: localhost:5432 (password: `password`)
- Redis: localhost:6379

#### Docker Commands
```bash
# Start services
docker-compose up --build

# Run Rails commands in container
docker-compose exec app ./bin/rails console
docker-compose exec app ./bin/rails db:migrate

# Stop services
docker-compose down

# Clean up (removes volumes)
docker-compose down -v
```

## Authentication

This application uses **Devise** with **JWT** (JSON Web Tokens) for authentication. The authentication system provides secure user registration, login, and session management.

### Authentication Features

- **JWT-based authentication** - Stateless authentication using JSON Web Tokens
- **User registration** - Create new user accounts
- **Secure login/logout** - Session management with JWT tokens
- **Password recovery** - Reset password functionality
- **JWT blacklisting** - Revoked tokens are tracked to prevent reuse

### API Endpoints

All authentication endpoints return JSON responses and expect JSON payloads.

#### User Registration
```bash
POST /signup
Content-Type: application/json

{
  "user": {
    "email": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }
}
```

**Response:**
```json
{
  "status": { "code": 200, "message": "Signed up successfully." },
  "data": {
    "id": 1,
    "email": "user@example.com",
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
}
```

#### User Login
```bash
POST /login
Content-Type: application/json

{
  "user": {
    "email": "user@example.com",
    "password": "password123"
  }
}
```

**Response:**
```json
{
  "status": { "code": 200, "message": "Logged in successfully." },
  "data": {
    "id": 1,
    "email": "user@example.com",
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
}
```

#### User Logout
```bash
DELETE /logout
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "status": 200,
  "message": "Logged out successfully."
}
```

#### Password Reset
```bash
POST /password
Content-Type: application/json

{
  "user": {
    "email": "user@example.com"
  }
}
```

### Using JWT Tokens

After successful login, include the JWT token in the `Authorization` header for authenticated requests:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

### Testing Authentication

```bash
# Create a test user
./bin/rails console
user = User.create(email: 'test@example.com', password: 'password123')

# Test login via API
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"test@example.com","password":"password123"}}'
```

## Testing

This application uses RSpec for testing. Run the test suite with:

```bash
# Run all tests
./bin/rails spec

# Run tests with coverage report
COVERAGE=true ./bin/rails spec

# Run specific test file
./bin/rails spec spec/models/user_spec.rb

# Run tests with debugging
./bin/rails spec --format documentation
```

### Test Structure

- **Models**: `spec/models/` - Unit tests for ActiveRecord models
- **Controllers**: `spec/controllers/` - Integration tests for API endpoints
- **Factories**: `spec/factories/` - Test data factories using FactoryBot

### Code Quality Tools

```bash
# Run all linters and static analysis
bundle exec rubocop          # Ruby style guide compliance
bundle exec reek             # Code smell detection
bundle exec brakeman         # Security vulnerability scanning

# Auto-fix RuboCop offenses
bundle exec rubocop -a
```

## Deployment

This application uses Kamal for deployment. See `config/deploy.yml` for configuration.
