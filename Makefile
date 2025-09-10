.PHONY: build run stop clean logs help

# Variablen
IMAGE_NAME = elementary-codespace
CONTAINER_NAME = elementary-codespace-container

help: ## Zeigt diese Hilfe an
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Baut das Docker Image
	docker build -t $(IMAGE_NAME) .

run: ## Startet den Container
	docker run -d \
		--name $(CONTAINER_NAME) \
		--privileged \
		--shm-size=2gb \
		-p 6080:6080 \
		-p 5901:5901 \
		-v $(PWD):/workspace \
		$(IMAGE_NAME)

stop: ## Stoppt und entfernt den Container
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || true

clean: stop ## Bereinigt Container und Image
	docker rmi $(IMAGE_NAME) || true

logs: ## Zeigt Container Logs
	docker logs -f $(CONTAINER_NAME)

shell: ## Öffnet eine Shell im Container
	docker exec -it $(CONTAINER_NAME) /bin/bash

restart: stop run ## Startet den Container neu

status: ## Zeigt Container Status
	docker ps | grep $(CONTAINER_NAME) || echo "Container nicht gefunden"
