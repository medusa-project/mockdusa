# Mockdusa

This is a minimal mock, based on [Sinatra](http://sinatrarb.com), of the
JSON endpoints of the
[Medusa Collection Registry](https://github.com/medusa-project/medusa-collection-registry).
It provides enough functionality against which to test
[Kumquat](https://github.com/medusa-project/kumquat),
[medusa-client](https://github.com/medusa-project/medusa-client), and perhaps
other projects. The goal is a mock Medusa instance whose content is easy to
tailor for tests, and more stable, without having to test against the
production Medusa service.

# How it works

The basic idea is that repository fixture content resides in a directory tree
that the HTTP endpoints read and supply on-the-fly. There is no database--UUIDs
(and, for files and directories, IDs) are auto-generated based on relative path
checksums, which are stable enough to test against.

By default, the content directory is located at `./content/`, but the path can
be overridden using the `REPOSITORY_ROOT` environment variable.

An S3 server can be pointed to this location to simulate S3 access to Medusa.

# Mocked endpoints

* `/repositories.json`
* `/repositories/:id.json`
* `/collections.json`
* `/collections/:id.json`
* `/file_groups/:id.json`
* `/cfs_directories/:id.json`
* `/cfs_directories/:id/show_tree.json`
* `/cfs_files/:id.json`
* `/uuids/:uuid.json`

# Content structure

The content tree is based on the Medusa data model:

```
content/
    repositories/
        :id/
            collections/
                :id/
                    file_groups/
                        :id/
                            root/
                                <arbitrary file/directory tree>
                            info.yml
                    info.yml
            info.yml
```

An application that wants to test using Mockdusa should create its own content
directory and set `REPOSITORY_ROOT` to its path.

## Notes

* IDs for repositories, collections, and file groups are their integer
  directory names, which must be unique among the same entity class across all
  branches of the tree.
* IDs for directories and files are auto-generated.

# Getting started

## Locally

```sh
$ bundle install
$ bundle exec rackup --quiet
```
Mockdusa is now listening on port 4567. The HTTP Basic username is `medusa`
and the secret is `secret`.

## With Docker

```sh
$ docker build -t mockdusa .
$ docker run -p 4567:4567 mockdusa
```
Mockdusa is now listening on port 4567 and using the same HTTP Basic
credentials as above.

Mockdusa can also run as a docker-compose service. The `scripts/ecr_push.sh`
script is used to push it to AWS ECR. That image can then be referred to in a 
`docker-compose.yml` file:

```yaml
version: '3'
services:
  mockdusa:
    image: 721945215539.dkr.ecr.us-east-2.amazonaws.com/mockdusa:latest
    environment:
      REPOSITORY_ROOT: /repo
    volumes:
      - /path/to/repo/content:/repo:ro
  # other services...
```
Other services can then connect to `http://mockdusa`.

To obtain credentials to access that image, we (at UIUC) would log into AWS
using the `aws login` command (which is provided by the `awscli_login` egg,
e.g. `pip install awscli_login`.) We could also create an IAM user with
permission to pull ECR images.

# Testing

## Locally

```sh
$ rake test
```

## In Docker

```sh
$ docker build -t mockdusa . \
    && docker run -p 4567:4567 --entrypoint rake mockdusa test
```
