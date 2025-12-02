APP_NAME := APP_NAME_TEMP
TAG := latest
REGISTRY := 192.168.100.8:5000
IMAGE := $(APP_NAME):$(TAG)
REMOTE_IMAGE := $(REGISTRY)/$(IMAGE)


build:
	docker build --build-arg PROJECT=$(APP_NAME) -t $(IMAGE) .

push:
	docker tag $(IMAGE) $(REMOTE_IMAGE)
	docker push $(REMOTE_IMAGE)

deploy:
	sed "s/APPNAME/$(APP_NAME)/g" k3s.yml | sudo k3s kubectl apply -f -

node-status:
	sudo k3s kubectl get nodes

pod:
	sudo k3s kubectl get pods

delete:
	sudo k3s kubectl delete -f k3s.yaml

delete-redis:
	redis-cli DEL $(APP_NAME):requests
	redis-cli DEL $(APP_NAME):dupefilter
	redis-cli DEL $(APP_NAME):items

test: build
	docker run --rm $(IMAGE)

all: build push deploy

git-commit:
	@printf "Enter commit message: "
	@read msg && \
	git add . && \
	git commit -m "$$msg" && \
	git push origin main

export:
	redis-cli LRANGE $(APP_NAME):items 0 -1 > dump.txt
	uv run export.py
	uv run reorder.py
	uv run summary.py
