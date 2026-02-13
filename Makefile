setup:
	@test -e .env || cp .env.example .env
	@docker build --progress=plain -f Containerfile -t mega-webdav .

destroy:
	-@docker rm -fv mega-webdav

up: HTTP_PORT = "80"
up:
	@docker run \
		--env-file .env \
		--name mega-webdav \
		--rm \
		-p 127.0.0.1:$(HTTP_PORT):80 \
		-d \
		mega-webdav
	@docker logs -f mega-webdav

down:
	-@docker stop mega-webdav

shell:
	@docker exec -it mega-webdav /bin/sh

test:
	@$(CURDIR)/tests/index.sh
