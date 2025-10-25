# Smart Link Shortener

A Rails application for shortening URLs with smart features.

## Development Setup

### Using Docker (Recommended)

1. **Prerequisites:**
   - Docker and Docker Compose installed

2. **Start the development environment:**
   ```bash
   docker-compose up --build
   ```

3. **Access the application:**
   - Rails app: http://localhost:3000
   - PostgreSQL: localhost:5432 (password: `password`)
   - Redis: localhost:6379

4. **Run Rails commands:**
   ```bash
   docker-compose exec app ./bin/rails console
   docker-compose exec app ./bin/rails db:migrate
   docker-compose exec app ./bin/rake
   ```

5. **Stop the environment:**
   ```bash
   docker-compose down
   ```

### Features

- **Bundle Cache**: Gems are cached in a Docker volume for faster rebuilds
- **Auto DB Migration**: Database is automatically prepared when the app starts
- **Hot Reload**: Code changes are reflected immediately due to volume mounting
- **PostgreSQL & Redis**: Full database and caching setup included

### Local Development (Without Docker)

1. **Prerequisites:**
   - Ruby 3.4.7
   - PostgreSQL
   - Redis

2. **Install dependencies:**
   ```bash
   bundle install
   ```

3. **Setup database:**
   ```bash
   ./bin/rails db:create
   ./bin/rails db:migrate
   ```

4. **Start the server:**
   ```bash
   ./bin/rails server
   ```

## Testing

```bash
./bin/rails test
```

## Deployment

This application uses Kamal for deployment. See `config/deploy.yml` for configuration.
