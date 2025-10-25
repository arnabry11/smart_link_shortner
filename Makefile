.PHONY: help build up down restart logs console db-migrate db-reset test clean

# Default target
help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

# Docker commands
build: ## Build the Docker images
	docker-compose build

up: ## Start the development environment
	docker-compose up -d

up-logs: ## Start the development environment and show logs
	docker-compose up

down: ## Stop the development environment
	docker-compose down

restart: ## Restart the development environment
	docker-compose restart

logs: ## Show logs from all services
	docker-compose logs -f

console: ## Open Rails console
	docker-compose exec app ./bin/rails console

db-migrate: ## Run database migrations
	docker-compose exec app ./bin/rails db:migrate

db-rollback: ## Rollback the last database migration
	docker-compose exec app ./bin/rails db:rollback

db-reset: ## Reset the database
	docker-compose exec app ./bin/rails db:reset

db-seed: ## Seed the database
	docker-compose exec app ./bin/rails db:seed

test: ## Run the test suite
	docker-compose exec app ./bin/rails test

routes: ## Show Rails routes
	docker-compose exec app ./bin/rails routes

# Cleanup commands
clean: ## Remove all containers, volumes, and images
	docker-compose down -v --rmi all

deep-clean: ## Remove everything including bundle cache
	docker-compose down -v --rmi all
	docker volume rm smart_link_shortner_bundle smart_link_shortner_postgres_data smart_link_shortner_redis_data 2>/dev/null || true
