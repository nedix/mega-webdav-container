setup:
	@test -e .env || cp .env.example .env
	@docker build --progress=plain -f Containerfile -t mega-webdav .

destroy:
	-@docker rm -fv mega-webdav

up: HTTP_PORT = "80"
up:
	@docker run --rm -d --name mega-webdav \
        --env-file .env \
        -p 127.0.0.1:$(HTTP_PORT):80 \
        mega-webdav
	@docker logs -f mega-webdav

down:
	-@docker stop mega-webdav

shell:
	@docker exec -it mega-webdav /bin/sh

test:
	@$(CURDIR)/tests/index.sh
