# Makefile commands

## Setup

Build the container.

Command: `make setup`


## Destroy

Stop the container and remove volumes.

Command: `make destroy`


## Up

Start the container.

Command: `make up`

Options:

| Key       | Type    | Default |
|-----------|---------|---------|
| HTTP_PORT | integer | 80      |


## Down

Stop the container.

Command: `make down`


## Shell

Attach an interactive shell to the container.

Command: `make shell`


## Test

Run all tests.

Command: `make test`
