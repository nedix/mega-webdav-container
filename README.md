# [mega-webdav-container][project]

The purpose of this container is to interact with MEGA.nz Cloud Drives using the WebDAV protocol.


## Table of contents

- [Configuration](#configuration)
  - [Environment](#environment)
  - [Security](#security)
- [Usage](#usage)
  - [1. Start the container](#1-start-the-container)
  - [2. Browse the files](#2-browse-the-files)
- [Development](#development)


## Configuration


### Environment

You can configure the container by making use of the following environment variables.
Add them to the `.env` file and use `--env-file=.env` or use the `-e` flag with the `docker run` command.

| Variable                          | Required                  | Description                                                |
|-----------------------------------|---------------------------|------------------------------------------------------------|
| MEGA_EMAIL                        | Yes                       | Email associated with a MEGA.nz Cloud Drive account        |
| MEGA_PASSWORD                     | Yes                       | Password associated with a MEGA.nz Cloud Drive account     |
| MEGA_DIRECTORY                    | No                        | Use a sub-directory from a MEGA.nz Cloud Drive             |
| [WEBDAV_USERNAME](#security)      | With WEBDAV_PASSWORD_HASH | Username to protect the WebDAV connection                  |
| [WEBDAV_PASSWORD_HASH](#security) | With WEBDAV_USERNAME      | sha512 hash of a password to protect the WebDAV connection |



### Security

```shell
    -e WEBDAV_USERNAME="user" \
    -e WEBDAV_PASSWORD_HASH="$(echo 'secret' | mkpasswd -P0 -msha512)" \
```


## Usage


### 1. Start the container

The following command is a minimal example to get the container up and running:

```shell
docker run --rm --pull always --name mega-webdav \
    -p 127.0.0.1:80:80 \
    -e MEGA_EMAIL="foo" \
    -e MEGA_PASSWORD="bar" \
    nedix/mega-webdav
```


### 2. Browse the files

With your file manager navigate to [127.0.0.1:80](http://127.0.0.1:80) and optionally sign in with your WebDAV credentials.


## Development

Please refer to the [Makefile documentation](/docs/make.md) for instructions to build and run the container if you have cloned this repository.

Please refer to the [nedix/actions repository](https://github.com/nedix/actions) for instructions to configure your secrets if you have forked this repository.


[project]: https://hub.docker.com/r/nedix/mega-webdav
