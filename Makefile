APP_NAME := activityjapan
TAG := latest
REGISTRY := 192.168.100.8:5000
IMAGE := $(APP_NAME):$(TAG)
REMOTE_IMAGE := $(REGISTRY)/$(IMAGE)


build:
	docker build -t $(IMAGE) .

push:
	docker tag $(IMAGE) $(REMOTE_IMAGE)
	docker push $(REMOTE_IMAGE)

deploy:
	sudo k3s kubectl apply -f k3s/daemonset.yaml

pod:
	sudo k3s kubectl get pods

delete:
	sudo k3s kubectl delete -f k3s/daemonset.yaml

delete-redis:
	redis-cli DEL $(APP_NAME)spider:requests
	redis-cli DEL $(APP_NAME)spider:dupefilter
	redis-cli DEL $(APP_NAME)spider:items

test: build
	docker run --rm $(IMAGE)

all: build push deploy

export:
	redis-cli LRANGE $(APP_NAME)spider:items 0 -1 > dump.txt
	uv run export.py
	uv run reorder.py
	head output.csv
