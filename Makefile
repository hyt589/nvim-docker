.PHONY: build

build:
	docker build -t l4t-base-dev .

.PHONY: run

run:
	docker run -it l4t-base-dev

.PHONY: rebuild

rebuild:
	docker build --no-cache -t l4t-base-dev .
