APP_NAME := APP_NAME_TEMP
TAG := latest
REGISTRY := 192.168.100.3:5000
REDIS_HOST := 192.168.100.3:6379
IMAGE := $(APP_NAME):$(TAG)
REMOTE_IMAGE := $(REGISTRY)/$(IMAGE)


build:
	docker build --build-arg PROJECT=$(APP_NAME) -t $(IMAGE) .

push:
	docker tag $(IMAGE) $(REMOTE_IMAGE)
	docker push $(REMOTE_IMAGE)

deploy:
	sed "s/APPNAME/$(APP_NAME)/g" k3s.yml | sudo k3s kubectl apply -f -

nodes:
	sudo k3s kubectl get nodes

pods:
	sudo k3s kubectl get pods

delete:
	sudo k3s kubectl delete -f k3s.yml

delete-redis:
	redis-cli DEL $(APP_NAME)_s:requests -h $(REDIS_HOST)
	redis-cli DEL $(APP_NAME)_s:dupefilter -h $(REDIS_HOST)
	redis-cli DEL $(APP_NAME)_s:items -h $(REDIS_HOST)

test:
	uv run scrapy crawl $(APP_NAME)_s -o output.csv

test-docker: build
	docker run --rm $(IMAGE)

distribute: build push deploy

git-commit:
	@printf "Enter commit message: "
	@read msg && \
	git add . && \
	git commit -m "$$msg" && \
	git push origin main

export:
	redis-cli LRANGE $(APP_NAME)_s:items 0 -1 > dump.txt
	uv run export.py
	uv run reorder.py
	uv run summary.py

