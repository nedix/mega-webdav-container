# [mega-webdav-container][project]

The purpose of this container is to interact with a MEGA.nz Cloud Drive over a webdav connection.


## Table of contents

- [Usage](#usage)
  - [1. Start the container](#1-start-the-container)
  - [2. Browse files](#2-browse-files)
- [Configuration](#configuration)
  - [Environment](#environment)
  - [Security](#security)
- [Development](#development)


## Usage


### 1. Start the container

The following command is a minimal example to get you up and running:

```shell
docker run --rm --pull always --name mega-webdav \
    -p 127.0.0.1:80:80 \
    -e MEGA_EMAIL="foo" \
    -e MEGA_PASSWORD="bar" \
    nedix/mega-webdav
```


### 2. Browse files

With your file manager navigate to [127.0.0.1:80](http://127.0.0.1:80) and sign in with your webdav credentials.


## Configuration


### Environment

You can configure the container by making use of the following environment variables.
Add them to the `docker run` command with the `-e` flag.

| Variable                          | Required                  | Description                                                |
|-----------------------------------|---------------------------|------------------------------------------------------------|
| MEGA_EMAIL                        | Yes                       | Email associated with a MEGA.nz Cloud Drive account        |
| MEGA_PASSWORD                     | Yes                       | Password associated with a MEGA.nz Cloud Drive account     |
| MEGA_DIRECTORY                    | No                        | Use a sub-directory from a MEGA.nz Cloud Drive             |
| [WEBDAV_USERNAME](#security)      | With WEBDAV_PASSWORD_HASH | Username to protect the webdav connection                  |
| [WEBDAV_PASSWORD_HASH](#security) | With WEBDAV_USERNAME      | sha512 hash of a password to protect the webdav connection |



### Security


```shell
WEBDAV_NAME="user"
WEBDAV_PASSWORD_HASH="$(echo 'secret' | mkpasswd -P0 -msha512)"
```


## Development

Please refer to the [Makefile documentation](/docs/make.md) for instructions to run the project from a clone of this repository.


[project]: https://hub.docker.com/r/nedix/mega-webdav
