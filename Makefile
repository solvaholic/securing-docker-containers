default: build

build:
	@echo "Building Hugo Builder container..."
	@docker build -t lp/hugo-builder .
	@echo "Hugo Builder container built!"
	@docker images lp/hugo-builder

hugo:
	@echo "Building thing..."
	@docker run -dt --rm -v "$(realpath ./orgdocs)":/src lp/hugo-builder hugo
	@echo "Thing built!"
	
server:
	@echo "Starting server..."
	@docker run -dt --rm -v "$(realpath ./orgdocs)":/src -p 1313:1313 lp/hugo-builder hugo server -w --bind=0.0.0.0
	@echo "Server started!"
	@docker ps

static:
	@echo "Performing static analysis..."
	@hadolint Dockerfile
	@echo "Static analysis performed!"

.PHONY: build
