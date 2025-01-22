setup:
	@docker build --progress=plain -f Containerfile -t mega-webdav .

up: WEBDAV_PORT = 80
up:
	@docker run --rm --name mega-webdav \
        --env-file .env \
        -p 127.0.0.1:$(WEBDAV_PORT):80 \
        mega-webdav

down:
	-@docker stop mega-webdav

shell:
	@docker exec -it mega-webdav /bin/sh
