setup:
	@docker build . -t mega-webdav --progress=plain

up: WEBDAV_PORT = 80
up:
	@docker run --rm --name mega-webdav \
        --cap-add NET_ADMIN \
        -v /sys/fs/cgroup/mega-webdav:/sys/fs/cgroup:rw \
        --env-file .env \
        -p 127.0.0.1:$(WEBDAV_PORT):80 \
        mega-webdav

down:
	-@docker stop mega-webdav

shell:
	@docker exec -it mega-webdav /bin/sh
