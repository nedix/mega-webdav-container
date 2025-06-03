# [mega-webdav-container][project]

The purpose of this container is to connect with a MEGA.nz Cloud Drive using a webdav connection.


## Table of contents


- [Usage](#usage)
  - [1. Prerequisites](#1-prerequisites)
  - [2. Start the container](#2-start-the-container)
  - [3. Browse Cloud Drive contents](#3-browse-cloud-drive-contents)
- [Configuration](#configuration)
  - [Environment](#environment)
  - [Credentials](#credentials)
- [Development](#development)


## Usage


### 1. Prerequisites

1. You must use the `MEGA_EMAIL` environment variable with the email of your MEGA.nz account.
1. You must use the `MEGA_PASSWORD` environment variable with the password of your MEGA.nz account.
1. You may optionally use [webdav credentials](#credentials) or omit them completely.


### 2. Start the container

The following command is a minimal example to get you up and running:

```shell
docker run --rm --pull always --name mega-webdav \
    -p 127.0.0.1:80:80 \
    -e MEGA_EMAIL="foo" \
    -e MEGA_PASSWORD="bar" \
    nedix/mega-webdav
```

### 3. Browse Cloud Drive contents

Point your file manager to `127.0.0.1:80` and sign in with your webdav credentials.


## Configuration

### Environment

You may configure the container by making use of the following environment variables.
Add them to the `docker run` command with the `-e` flag.

| Variable                             | Required                  | Description                                                |
|--------------------------------------|---------------------------|------------------------------------------------------------|
| MEGA_EMAIL                           | Yes                       | Email associated with a MEGA.nz Cloud Drive account        |
| MEGA_PASSWORD                        | Yes                       | Password associated with a MEGA.nz Cloud Drive account     |
| [WEBDAV_USERNAME](#credentials)      | With WEBDAV_PASSWORD_HASH | Username to protect the webdav connection                  |
| [WEBDAV_PASSWORD_HASH](#credentials) | With WEBDAV_USERNAME      | sha512 hash of a password to protect the webdav connection |


### Credentials

```shell
WEBDAV_USERNAME="user"
WEBDAV_PASSWORD_HASH="$(echo 'secret' | mkpasswd -P0 -msha512)"
```


## Development

Please refer to the [Makefile documentation](/docs/make.md) for instructions to run the project from a cloned repository.


[project]: https://hub.docker.com/r/nedix/mega-webdav
