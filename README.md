# [mega-webdav-container][project]

Serve a webdav directory from a MEGA.nz Cloud Drive.


## Usage

### 1. Start the container

```shell
docker run --rm --pull always --name mega-webdav \
    -p 127.0.0.1:80:80 \
    -e MEGA_EMAIL="foo" \
    -e MEGA_PASSWORD="bar" \
    -e WEBDAV_USERNAME="user" \
    -e WEBDAV_PASSWORD_HASH="$(echo 'secret' | mkpasswd -P0 -msha512)" \
    nedix/webdav-container
```

### 2. Browse contents

Navigate to `127.0.0.1:80` and sign in with your webdav credentials.


[project]: https://hub.docker.com/r/nedix/mega-webdav
